import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:digicamp_interface/injection_container.dart';
import 'package:digicamp_interface/src/commons/responsive_layout_builder.dart';
import 'package:digicamp_interface/src/models/models.dart';
import 'package:digicamp_interface/src/utils/extensions/string_extension.dart';
import 'package:digicamp_interface/src/utils/services/rest_api.dart';

class CampaignSummaryPage extends StatefulWidget {
  const CampaignSummaryPage({
    super.key,
    required this.campaignId,
  });
  final int campaignId;

  @override
  State<CampaignSummaryPage> createState() => _CampaignSummaryPageState();
}

class _CampaignSummaryPageState extends State<CampaignSummaryPage> {
  final _horizontalScrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Data<CampaignSummaryModel>>(
      future: locator<ApiClient>().campaignSummary(
        campaignId: widget.campaignId,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.data == null || !snapshot.data!.isSuccess) {
          return const Center(
            child: Text('Data not found'),
          );
        }

        final data = snapshot.data!.data!;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 20,
                runSpacing: 20,
                children: [
                  CallsChart(
                    values: [
                      MapEntry('Answered', data.answeredCallsUnique),
                      MapEntry('Ongoing', data.ongoingCalls),
                      MapEntry('Unanswered', data.unansweredCalls),
                      MapEntry('To Be Dialed', data.toBeDialed),
                      MapEntry('Cancelled', data.cancelledCalls),
                    ],
                    totalCalls: data.totalCallsUnique.toInt(),
                  ),
                  CallDurationChart(
                    averageDuration: data.averageCallDurationAnswered!,
                    values: [
                      data.callsDuration0To10,
                      data.callsDuration11To20,
                      data.callsDuration21To30,
                      data.callsDuration31To40,
                      data.callsDuration41To50,
                      data.callsDuration51To60,
                      data.callsDuration61To90,
                      data.callsDuration91To120,
                      data.callsDuration121Plus,
                    ],
                  ),
                ],
              ),
              const Gap(30),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Extensions Pressed Analysis',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Scrollbar(
                      controller: _horizontalScrollController,
                      child: SingleChildScrollView(
                        controller: _horizontalScrollController,
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: [
                            'Extension',
                            'Dtmf 1',
                            'Dtmf 2',
                            'Dtmf 3',
                            'Dtmf 4',
                            'Dtmf 5',
                            'Dtmf 6',
                            'Dtmf 7',
                            'Dtmf 8',
                            'Dtmf 9',
                            'Dtmf 0',
                          ].map((column) {
                            return DataColumn(
                              label: Text(column),
                            );
                          }).toList(),
                          rows:
                              data.extensionsPressedRecent.entries.map((entry) {
                            return DataRow(
                              cells: [
                                DataCell(Text(
                                  entry.key.replaceAll('_', ' ').toStudlyCase(),
                                )),
                                ...entry.value.values.map((value) {
                                  return DataCell(Text(
                                    value.toString(),
                                  ));
                                }),
                                ...List.generate(10 - entry.value.values.length,
                                    (index) {
                                  return const DataCell(Text(
                                    'N/A',
                                  ));
                                })
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CallsChart extends StatefulWidget {
  const CallsChart({
    super.key,
    required this.values,
    required this.totalCalls,
  });
  final List<MapEntry<String, int>> values;
  final int totalCalls;
  @override
  State<StatefulWidget> createState() => CallsChartState();
}

class CallsChartState extends State<CallsChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final total = widget.values.fold<double>(0, (previousValue, element) {
      return previousValue + element.value;
    });
    return ResponsiveLayoutBuilder(
      small: (context, constraints, child) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.all(16),
          height: 300,
          child: child!,
        );
      },
      large: (context, constraints, child) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.all(16),
          height: 450,
          width: constraints.maxWidth * 0.48,
          child: child!,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Calls ${widget.totalCalls}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex = pieTouchResponse
                                .touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      sectionsSpace: 0,
                      centerSpaceRadius: 40,
                      sections: List.generate(widget.values.length, (i) {
                        final isTouched = i == touchedIndex;
                        final fontSize = isTouched ? 14.0 : 10.0;
                        final radius = isTouched ? 50.0 : 40.0;
                        const shadows = [
                          Shadow(
                            color: Colors.black,
                            blurRadius: 2,
                          ),
                        ];
                        final value = widget.values[i].value / total * 100;
                        return PieChartSectionData(
                          color: _buildColors(i),
                          value: double.parse(value.toStringAsFixed(2)),
                          title: '${value.toStringAsFixed(2)}%',
                          radius: radius,
                          titleStyle: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xffffffff),
                            shadows: shadows,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 50),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: widget.values.asMap().entries.map((entry) {
                        return Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              color: _buildColors(entry.key),
                            ),
                            const Gap(5),
                            Text("${entry.value.key} (${entry.value.value})"),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _buildColors(int index) {
    switch (index) {
      case 0:
        return Colors.green;
      case 1:
        return Colors.yellow;
      case 2:
        return Colors.red;
      case 3:
        return Colors.blue;
      case 4:
        return Colors.black;
      default:
        return Colors.black;
    }
  }
}

class CallDurationChart extends StatefulWidget {
  const CallDurationChart({
    super.key,
    required this.values,
    required this.averageDuration,
  });
  final double averageDuration;
  final List<int> values;

  @override
  State<StatefulWidget> createState() => CallDurationChartState();
}

class CallDurationChartState extends State<CallDurationChart> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayoutBuilder(
      small: (context, constraints, child) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.all(16),
          height: 450,
          child: child!,
        );
      },
      large: (context, constraints, child) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.all(16),
          height: 450,
          width: constraints.maxWidth * 0.5,
          child: child!,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Call Duration',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                'Average: ${widget.averageDuration}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const Gap(20),
          Expanded(
            child: BarChart(
              randomData(),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData makeGroupData(
    int x,
    double y,
  ) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.zero,
          width: 20,
        ),
      ],
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    double max =
        widget.values.reduce((value, element) => value + element).toDouble();

    const style = TextStyle(
      color: Colors.black,
      fontSize: 10,
    );
    List<String> callDurations = [
      '0-10',
      '11-20',
      '21-30',
      '31-40',
      '41-50',
      '51-60',
      '61-90',
      '91-120',
      '121+',
    ];
    final per = (widget.values[value.toInt()] / max) * 100;
    Widget text = Text(
      "${callDurations[value.toInt()]}\n"
      "(${widget.values[value.toInt()]})\n"
      "(${per.toStringAsFixed(2)}%)",
      style: style,
      textAlign: TextAlign.center,
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 10,
      child: text,
    );
  }

  BarChartData randomData() {
    double max = 0;
    for (var value in widget.values) {
      if (value > max) {
        max = value.toDouble();
      }
    }
    return BarChartData(
      maxY: max,
      barTouchData: BarTouchData(
        enabled: false,
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: getTitles,
            reservedSize: 50,
          ),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(
            reservedSize: 50,
            showTitles: true,
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: widget.values.asMap().entries.map((e) {
        return makeGroupData(e.key, e.value.toDouble());
      }).toList(),
      gridData: const FlGridData(show: false),
    );
  }
}
