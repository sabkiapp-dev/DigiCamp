import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:digicamp_interface/injection_container.dart';
import 'package:digicamp_interface/src/commons/general_dialogs.dart';
import 'package:digicamp_interface/src/config/app_constants.dart';
import 'package:digicamp_interface/src/config/font_sizes.dart';
import 'package:digicamp_interface/src/models/models.dart';
import 'package:digicamp_interface/src/providers/providers.dart';
import 'package:digicamp_interface/src/screens/campaigns/widgets/widgets.dart';
import 'package:digicamp_interface/src/screens/view_contacts/widgets/widgets.dart';
import 'package:digicamp_interface/src/utils/extensions/size_extension.dart';
import 'package:digicamp_interface/src/utils/palette.dart';
import 'package:digicamp_interface/src/utils/services/rest_api.dart';

class DialPlanPage extends StatefulWidget {
  const DialPlanPage({
    super.key,
    required this.id,
  });
  final int id;

  @override
  State<DialPlanPage> createState() => _DialPlanPageState();
}

class _DialPlanPageState extends State<DialPlanPage> {
  CampaignModel? _campaignDetail;
  List<DialPlanModel> _dialPlan = [];
  bool _isLoading = true;
  final _columns = [
    'Extension Id',
    'Main Voice',
    'Name Spell',
    'Option Voice',
    'DTMF 1',
    'DTMF 2',
    'DTMF 3',
    'DTMF 4',
    'DTMF 5',
    'DTMF 6',
    'DTMF 7',
    'DTMF 8',
    'DTMF 9',
    'DTMF 0',
    'Continue To',
    'SMS Template',
    'Send AMS After',
  ];
  final ScrollController _horizontalScroll = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _init();
    });
  }

  void _init() async {
    final campaignResponse =
        await locator<ApiClient>().campaignDetail(widget.id);

    if (campaignResponse.isSuccess) {
      _campaignDetail = campaignResponse.data;

      final dialPlanResponse = await locator<ApiClient>().dialPlans(widget.id);

      if (dialPlanResponse.isSuccess) {
        _dialPlan = dialPlanResponse.data!
          ..sort((a, b) => a.extensionId!.compareTo(b.extensionId!));
      }
    }
    _isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final dtmfEntries = _dialPlan
        .where((dialPlan) =>
            dialPlan.mainVoiceId != null || dialPlan.optionVoiceId != null)
        .toList();

    if (_isLoading) {
      return Center(
        child: LoadingAnimationWidget.fourRotatingDots(
          color: Palette.primaryColor,
          size: 50,
        ),
      );
    }
    if (_campaignDetail == null) {
      return const Center(
        child: Text("Invalid campaign"),
      );
    }
    final namedStatus = switch (_campaignDetail?.status) {
      0 => const MapEntry('Not Created', Colors.transparent),
      1 => const MapEntry('Running', Colors.green),
      2 => const MapEntry('Paused', Colors.yellow),
      3 => const MapEntry('Completed', Colors.blue),
      4 => const MapEntry('Cancelled', Colors.red),
      5 => const MapEntry('Dial Plan Freezed', Colors.orange),
      _ => const MapEntry('Unknown', Colors.transparent),
    };

    final status = _campaignDetail?.status;

    return Column(
      children: [
        ListTile(
          title: Wrap(
            spacing: 5,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                _campaignDetail!.name!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: FontSizes.large,
                ),
              ),
              // const Gap(10),
              Container(
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: namedStatus.value,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "Status: ${namedStatus.key},",
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),
              ),
              // const Gap(5),
              Text(
                "Contacts Count: ${_campaignDetail!.contactCount ?? 0}",
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              )
            ],
          ),
          subtitle: Text(_campaignDetail!.description!),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // IconButton(
              //   onPressed: _addContacts,
              //   tooltip: "Add Contacts",
              //   icon: SvgPicture.asset(
              //     "assets/icons/add_contact_icon.svg",
              //     height: 20,
              //     width: 20,
              //   ),
              // ),
              IconButton(
                tooltip: "Edit Campaign",
                onPressed: () async {
                  await context.push(
                    AppRoutes.updateCampaign.path,
                    extra: _campaignDetail,
                  );
                  setState(() {});
                },
                icon: const Icon(Icons.edit),
              ),
            ],
          ),
        ),
        const Divider(
          height: 1,
          color: Colors.grey,
        ),
        IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Wrong Key Voice",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Palette.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (status == 0)
                      InkWell(
                        borderRadius: BorderRadius.circular(4),
                        onTap: _selectWrongKeyAudio,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Row(
                            children: [
                              Text(
                                _campaignDetail!.wrongKeyAudio?.voiceName ??
                                    'N/A',
                                style: TextStyle(
                                  color: _campaignDetail!.wrongKeyAudio == null
                                      ? Colors.grey
                                      : Colors.black,
                                ),
                              ),
                              const Gap(2),
                              InkWell(
                                borderRadius: BorderRadius.circular(50),
                                onTap: _campaignDetail!.wrongKeyAudio == null
                                    ? null
                                    : _clearWrongKeyAudio,
                                child: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Icon(
                                    _campaignDetail!.wrongKeyAudio == null
                                        ? Icons.arrow_drop_down
                                        : Icons.cancel,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Text(
                        _campaignDetail?.wrongKeyAudio?.voiceName ?? 'N/A',
                        style: TextStyle(
                          color: _campaignDetail?.wrongKeyAudio == null
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                  ],
                ),
              ),
              const VerticalDivider(
                color: Colors.grey,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "No Key Voice",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Palette.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (status == 0)
                      InkWell(
                        borderRadius: BorderRadius.circular(4),
                        onTap: _selectNoKeyAudio,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Row(
                            children: [
                              Text(
                                _campaignDetail!.noKeyAudio?.voiceName ?? 'N/A',
                                style: TextStyle(
                                  color: _campaignDetail!.noKeyAudio == null
                                      ? Colors.grey
                                      : Colors.black,
                                ),
                              ),
                              const Gap(2),
                              InkWell(
                                borderRadius: BorderRadius.circular(50),
                                onTap: _campaignDetail!.noKeyAudio == null
                                    ? null
                                    : _clearNoKeyAudio,
                                child: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Icon(
                                    _campaignDetail!.noKeyAudio == null
                                        ? Icons.arrow_drop_down
                                        : Icons.cancel,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Text(
                        _campaignDetail?.noKeyAudio?.voiceName ?? 'N/A',
                        style: TextStyle(
                          color: _campaignDetail?.wrongKeyAudio == null
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(
          color: Colors.grey,
          height: 1,
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Scrollbar(
                  controller: _horizontalScroll,
                  child: SingleChildScrollView(
                    controller: _horizontalScroll,
                    scrollDirection: Axis.horizontal,
                    child: status != 0
                        ? FreezedDialPlan(
                            dialPlan: _dialPlan,
                          )
                        : DataTable(
                            columns: _columns.map((column) {
                              return DataColumn(
                                label: Text(
                                  column,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            rows: [
                              for (final dialPlan in _dialPlan)
                                DataRow(
                                  cells: [
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(dialPlan.extensionId.toString()),
                                          const Gap(5),
                                          IconButton(
                                            onPressed: () =>
                                                _clearValue(dialPlan),
                                            icon: const Icon(
                                              Icons.cancel_outlined,
                                              color: Colors.red,
                                              size: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    /// Main voice
                                    DataCell(
                                      InkWell(
                                        borderRadius: BorderRadius.circular(4),
                                        onTap: () => _updateMainVoice(dialPlan),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4.0,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                dialPlan.mainVoiceId
                                                        ?.voiceName ??
                                                    'N/A',
                                                style: TextStyle(
                                                  color: dialPlan.mainVoiceId
                                                              ?.voiceName ==
                                                          null
                                                      ? Colors.grey
                                                      : Colors.black,
                                                ),
                                              ),
                                              const SizedBox(width: 2),
                                              const Icon(Icons.arrow_drop_down)
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    /// Name spell
                                    DataCell(
                                      DropdownButtonHideUnderline(
                                        child: DropdownButton<int>(
                                          padding: EdgeInsets.zero,
                                          items: [
                                            'No',
                                            'Male Voice',
                                            'Female Voice',
                                          ]
                                              .asMap()
                                              .entries
                                              .toList()
                                              .map((entry) {
                                            return DropdownMenuItem(
                                              value: entry.key,
                                              child: Text(entry.value),
                                            );
                                          }).toList(),
                                          hint: const Text("N/A"),
                                          disabledHint: const Text(
                                            "Please select SMS",
                                          ),
                                          onChanged: (v) => _updateNameSpell(
                                              value: v, dialPlan: dialPlan),
                                          isDense: true,
                                          value: dialPlan.nameSpell,
                                        ),
                                      ),
                                    ),

                                    /// Option voice
                                    DataCell(
                                      InkWell(
                                        borderRadius: BorderRadius.circular(4),
                                        onTap: () =>
                                            _updateOptionVoice(dialPlan),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                dialPlan.optionVoiceId
                                                        ?.voiceName ??
                                                    'N/A',
                                                style: TextStyle(
                                                  color: dialPlan.optionVoiceId
                                                              ?.voiceName ==
                                                          null
                                                      ? Colors.grey
                                                      : Colors.black,
                                                ),
                                              ),
                                              const SizedBox(width: 2),
                                              const Icon(Icons.arrow_drop_down),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    DataCell(
                                      DtmfOption(
                                        dialPlan: dialPlan,
                                        entries: dtmfEntries,
                                        value: dialPlan.dtmf1,
                                        onChanged: (int? dialPlanId) async {
                                          final previous = dialPlan.dtmf1;
                                          dialPlan.dtmf1 = dialPlanId;
                                          final response =
                                              await _saveChanges(dialPlan);
                                          if (!response) {
                                            dialPlan.dtmf1 = previous;
                                          }
                                          dialPlan.reset();
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                    DataCell(
                                      DtmfOption(
                                        dialPlan: dialPlan,
                                        entries: dtmfEntries,
                                        value: dialPlan.dtmf2,
                                        onChanged: (int? dialPlanId) async {
                                          final previous = dialPlan.dtmf2;
                                          dialPlan.dtmf2 = dialPlanId;
                                          final response =
                                              await _saveChanges(dialPlan);
                                          if (!response) {
                                            dialPlan.dtmf2 = previous;
                                          }
                                          dialPlan.reset();
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                    DataCell(
                                      DtmfOption(
                                        dialPlan: dialPlan,
                                        entries: dtmfEntries,
                                        value: dialPlan.dtmf3,
                                        onChanged: (int? dialPlanId) async {
                                          final previous = dialPlan.dtmf3;
                                          dialPlan.dtmf3 = dialPlanId;
                                          final response =
                                              await _saveChanges(dialPlan);
                                          if (!response) {
                                            dialPlan.dtmf3 = previous;
                                          }
                                          dialPlan.reset();
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                    DataCell(
                                      DtmfOption(
                                        dialPlan: dialPlan,
                                        entries: dtmfEntries,
                                        value: dialPlan.dtmf4,
                                        onChanged: (int? dialPlanId) async {
                                          final previous = dialPlan.dtmf4;
                                          dialPlan.dtmf4 = dialPlanId;
                                          final response =
                                              await _saveChanges(dialPlan);
                                          if (!response) {
                                            dialPlan.dtmf4 = previous;
                                          }
                                          dialPlan.reset();
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                    DataCell(
                                      DtmfOption(
                                        dialPlan: dialPlan,
                                        entries: dtmfEntries,
                                        value: dialPlan.dtmf5,
                                        onChanged: (int? dialPlanId) async {
                                          final previous = dialPlan.dtmf5;
                                          dialPlan.dtmf5 = dialPlanId;
                                          final response =
                                              await _saveChanges(dialPlan);
                                          if (!response) {
                                            dialPlan.dtmf5 = previous;
                                          }
                                          dialPlan.reset();
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                    DataCell(
                                      DtmfOption(
                                        dialPlan: dialPlan,
                                        entries: dtmfEntries,
                                        value: dialPlan.dtmf6,
                                        onChanged: (int? dialPlanId) async {
                                          final previous = dialPlan.dtmf6;
                                          dialPlan.dtmf6 = dialPlanId;
                                          final response =
                                              await _saveChanges(dialPlan);
                                          if (!response) {
                                            dialPlan.dtmf6 = previous;
                                          }
                                          dialPlan.reset();
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                    DataCell(
                                      DtmfOption(
                                        dialPlan: dialPlan,
                                        entries: dtmfEntries,
                                        value: dialPlan.dtmf7,
                                        onChanged: (int? dialPlanId) async {
                                          final previous = dialPlan.dtmf7;
                                          dialPlan.dtmf7 = dialPlanId;
                                          final response =
                                              await _saveChanges(dialPlan);
                                          if (!response) {
                                            dialPlan.dtmf7 = previous;
                                          }
                                          dialPlan.reset();
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                    DataCell(
                                      DtmfOption(
                                        dialPlan: dialPlan,
                                        entries: dtmfEntries,
                                        value: dialPlan.dtmf8,
                                        onChanged: (int? dialPlanId) async {
                                          final previous = dialPlan.dtmf8;
                                          dialPlan.dtmf8 = dialPlanId;
                                          final response =
                                              await _saveChanges(dialPlan);
                                          if (!response) {
                                            dialPlan.dtmf8 = previous;
                                          }
                                          dialPlan.reset();
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                    DataCell(
                                      DtmfOption(
                                        dialPlan: dialPlan,
                                        entries: dtmfEntries,
                                        value: dialPlan.dtmf9,
                                        onChanged: (int? dialPlanId) async {
                                          final previous = dialPlan.dtmf9;
                                          dialPlan.dtmf9 = dialPlanId;
                                          final response =
                                              await _saveChanges(dialPlan);
                                          if (!response) {
                                            dialPlan.dtmf9 = previous;
                                          }
                                          dialPlan.reset();
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                    DataCell(
                                      DtmfOption(
                                        dialPlan: dialPlan,
                                        entries: dtmfEntries,
                                        value: dialPlan.dtmf0,
                                        onChanged: (int? dialPlanId) async {
                                          final previous = dialPlan.dtmf0;
                                          dialPlan.dtmf0 = dialPlanId;
                                          final response =
                                              await _saveChanges(dialPlan);
                                          if (!response) {
                                            dialPlan.dtmf0 = previous;
                                          }
                                          dialPlan.reset();
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                    DataCell(
                                      DropdownButtonHideUnderline(
                                        child: DropdownButton<int>(
                                          padding: EdgeInsets.zero,
                                          items: [
                                            for (final entry in _dialPlan)
                                              DropdownMenuItem(
                                                value: entry.id,
                                                child: Text(
                                                  "Goto Extension ${entry.extensionId}",
                                                ),
                                              ),
                                          ],
                                          hint: const Text("N/A"),
                                          disabledHint: const Text(
                                            "Only Applicable If there are no DTMF's set",
                                          ),
                                          onChanged: dialPlan.hasOptions
                                              ? null
                                              : (v) async {
                                                  final previous =
                                                      dialPlan.continueTo;
                                                  dialPlan.continueTo = v;
                                                  final response =
                                                      await _saveChanges(
                                                          dialPlan);
                                                  if (!response) {
                                                    dialPlan.continueTo =
                                                        previous;
                                                  }
                                                  dialPlan.reset();
                                                  setState(() {});
                                                },
                                          isDense: true,
                                          value: dialPlan.continueTo,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      InkWell(
                                        borderRadius: BorderRadius.circular(4),
                                        onTap: () async {
                                          final previous = dialPlan.templateId;
                                          dialPlan.templateId = await context
                                              .push<SMSTemplateModel>(
                                                  AppRoutes.selectSms.path);

                                          final response =
                                              await _saveChanges(dialPlan);
                                          if (!response) {
                                            dialPlan.templateId = previous;
                                          }
                                          dialPlan.reset();
                                          setState(() {});
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                dialPlan.templateId
                                                        ?.templateName ??
                                                    'N/A',
                                                style: TextStyle(
                                                  color: dialPlan.templateId ==
                                                          null
                                                      ? Colors.grey
                                                      : Colors.black,
                                                ),
                                              ),
                                              const SizedBox(width: 2),
                                              const Icon(Icons.arrow_drop_down),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      SMSAfterWidget(
                                        dialPlan: dialPlan,
                                        onChanged: (int? value) async {
                                          final previous = dialPlan.smsAfter;
                                          dialPlan.smsAfter = value;
                                          final response =
                                              await _saveChanges(dialPlan);
                                          if (!response) {
                                            dialPlan.smsAfter = previous;
                                          }
                                          dialPlan.reset();
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              if (status == 0)
                                DataRow(
                                  cells: [
                                    DataCell(
                                      IconButton(
                                        onPressed: _addNewVoiceEntry,
                                        icon: const Icon(
                                          Icons.add_to_photos_rounded,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                    for (int i = 0;
                                        i < _columns.length - 1;
                                        i++)
                                      const DataCell(
                                        SizedBox(),
                                      ),
                                  ],
                                )
                            ],
                          ),
                  ),
                ),
                Wrap(
                  children: [
                    if (status != 0 && status != 4)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton.icon(
                          onPressed: _addContacts,
                          label: const Text('Add Contacts'),
                          icon: SvgPicture.asset(
                            "assets/icons/add_contact_icon.svg",
                            height: 20,
                            width: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    if (status == 0 && _dialPlan.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          onPressed: _freezeStatus,
                          label: const Text('Freeze Dial Plan'),
                          icon: const Icon(
                            Icons.severe_cold,
                            size: 20,
                          ),
                        ),
                      ),
                    if (status != 1 && status != 0)
                      if (_dialPlan.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            onPressed: _selectHosts,
                            label: const Text('Start Campaign'),
                            icon: const Icon(
                              Icons.play_arrow,
                              size: 20,
                            ),
                          ),
                        ),
                    if (status == 1)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow,
                          ),
                          onPressed: () => _changeStatus(2),
                          label: const Text('Pause Campaign'),
                          icon: const Icon(
                            Icons.pause,
                            size: 20,
                          ),
                        ),
                      ),
                    if (status != 5 && status != 0) ...[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurpleAccent,
                          ),
                          onPressed: () => context.go(
                            AppRoutes.campaignReport.path.replaceAll(
                              ':campaignId',
                              _campaignDetail!.id.toString(),
                            ),
                          ),
                          label: const Text('Campaign Report'),
                          icon: const Icon(
                            Icons.report,
                            size: 20,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () => context.go(
                            AppRoutes.campaignSummary.path.replaceAll(
                              ':campaignId',
                              _campaignDetail!.id.toString(),
                            ),
                          ),
                          label: const Text('Campaign Summary'),
                          icon: const Icon(
                            Icons.bar_chart_rounded,
                            size: 20,
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<bool> _saveChanges(DialPlanModel dialPlan) async {
    final response = await locator<ApiClient>().updateDialPlan(
      id: dialPlan.id!,
      nameSpell: dialPlan.nameSpell,
      extensionId: dialPlan.extensionId!,
      campaignId: dialPlan.campaign!,
      mainVoice: dialPlan.mainVoiceId?.id,
      optionVoice: dialPlan.optionVoiceId?.id,
      dtmf0: dialPlan.dtmf0,
      dtmf1: dialPlan.dtmf1,
      dtmf2: dialPlan.dtmf2,
      dtmf3: dialPlan.dtmf3,
      dtmf4: dialPlan.dtmf4,
      dtmf5: dialPlan.dtmf5,
      dtmf6: dialPlan.dtmf6,
      dtmf7: dialPlan.dtmf7,
      dtmf8: dialPlan.dtmf8,
      dtmf9: dialPlan.dtmf9,
      continueTo: dialPlan.continueTo,
      templateId: dialPlan.templateId?.id,
      smsAfter: dialPlan.smsAfter,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
        ),
      );
    }
    return response.isSuccess;
  }

  void _addNewVoiceEntry() async {
    context.read<HudProvider>().showProgress();
    final response = await locator<ApiClient>().addDialPlan(
      campaignId: widget.id,
    );
    if (response.isSuccess) {
      _dialPlan.add(response.data!);
    }
    context.read<HudProvider>().hideProgress();
    setState(() {});
  }

  void _freezeStatus() async {
    // if (_dialPlan.any((dialPlan) => dialPlan.isEmpty)) {
    //   QuickAlert.show(
    //     context: context,
    //     width: 200,
    //     type: QuickAlertType.warning,
    //     text: "There is dial plan with empty fields. Please fill all fields",
    //   );
    //   return;
    // }

    final status = await generalDialog(
      context: context,
      content: const Text(
        "Freezing dial plan is irreversible and can not be unfrozen.\nAre you sure you want to proceed?",
      ),
      actions: [
        TextButton(
          onPressed: () {
            context.pop(false);
          },
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            context.pop(true);
          },
          child: const Text("Freeze"),
        ),
      ],
    );

    if (status == false) {
      return;
    }

    context.read<HudProvider>().showProgress();
    final previous = _campaignDetail!.status;
    _campaignDetail!.status = 5;
    final response = await locator<ApiClient>().updateCampaignStatus(
      campaignId: _campaignDetail!.id!,
      status: _campaignDetail!.status!,
    );
    if (!response.isSuccess) {
      _campaignDetail!.status = previous;
    }
    setState(() {});
    if (mounted) {
      context.read<HudProvider>().hideProgress();
      QuickAlert.show(
        context: context,
        width: 200,
        type:
            response.isSuccess ? QuickAlertType.success : QuickAlertType.error,
        text: response.message,
      );
    }
  }

  void _clearValue(DialPlanModel dialPlan) async {
    context.read<HudProvider>().showProgress();
    dialPlan.clear();
    for (final dp in _dialPlan) {
      if (dp.id != dialPlan.id && dp.options.contains(dialPlan.id)) {
        if (dp.dtmf1 != null && dp.dtmf1 == dialPlan.id) {
          dp.dtmf1 = null;
        }
        if (dp.dtmf2 == dialPlan.id) {
          dp.dtmf2 = null;
        }
        if (dp.dtmf3 != null && dp.dtmf3 == dialPlan.id) {
          dp.dtmf3 = null;
        }
        if (dp.dtmf4 != null && dp.dtmf4 == dialPlan.id) {
          dp.dtmf4 = null;
        }
        if (dp.dtmf5 != null && dp.dtmf5 == dialPlan.id) {
          dp.dtmf5 = null;
        }
        if (dp.dtmf6 != null && dp.dtmf6 == dialPlan.id) {
          dp.dtmf6 = null;
        }
        if (dp.dtmf7 != null && dp.dtmf7 == dialPlan.id) {
          dp.dtmf7 = null;
        }
        if (dp.dtmf8 != null && dp.dtmf8 == dialPlan.id) {
          dp.dtmf8 = null;
        }
        if (dp.dtmf9 != null && dp.dtmf9 == dialPlan.id) {
          dp.dtmf9 = null;
        }
        if (dp.dtmf0 != null && dp.dtmf0 == dialPlan.id) {
          dp.dtmf0 = null;
        }
      }
      if (dp.modified) {
        await _saveChanges(dp);
        setState(() {});
      }
    }
    context.read<HudProvider>().hideProgress();
  }

  void _clearWrongKeyAudio() async {
    final audio = _campaignDetail!.wrongKeyAudio;
    if (audio != null) {
      final response = await locator<ApiClient>().updateCampaignAudio(
        campaignId: _campaignDetail!.id!,
        wrongKeyAudio: audio.id,
        noKeyAudio: _campaignDetail!.noKeyAudio?.id,
      );
      if (response.isSuccess) {
        _campaignDetail!.wrongKeyAudio = null;
        setState(() {});
      }
    }
  }

  void _clearNoKeyAudio() async {
    final audio = _campaignDetail!.noKeyAudio;
    if (audio != null) {
      final response = await locator<ApiClient>().updateCampaignAudio(
        campaignId: _campaignDetail!.id!,
        noKeyAudio: audio.id,
        wrongKeyAudio: _campaignDetail!.wrongKeyAudio?.id,
      );
      if (response.isSuccess) {
        _campaignDetail!.noKeyAudio = null;
        setState(() {});
      }
    }
  }

  void _selectNoKeyAudio() async {
    final audio = await context.push<AudioModel>(AppRoutes.selectAudio.path);
    if (audio != null) {
      final response = await locator<ApiClient>().updateCampaignAudio(
        campaignId: _campaignDetail!.id!,
        noKeyAudio: audio.id,
        wrongKeyAudio: _campaignDetail!.wrongKeyAudio?.id,
      );
      if (response.isSuccess) {
        _campaignDetail!.noKeyAudio = audio;
        setState(() {});
      }
    }
  }

  void _selectWrongKeyAudio() async {
    final audio = await context.push<AudioModel>(AppRoutes.selectAudio.path);
    if (audio != null) {
      final response = await locator<ApiClient>().updateCampaignAudio(
        campaignId: _campaignDetail!.id!,
        wrongKeyAudio: audio.id,
        noKeyAudio: _campaignDetail!.noKeyAudio?.id,
      );
      if (response.isSuccess) {
        _campaignDetail!.wrongKeyAudio = audio;
        setState(() {});
      }
    }
  }

  void _updateMainVoice(DialPlanModel dialPlan) async {
    final previous = dialPlan.mainVoiceId;
    dialPlan.mainVoiceId =
        await context.push<AudioModel>(AppRoutes.selectAudio.path);
    if (dialPlan.mainVoiceId != null) {
      final response = await _saveChanges(dialPlan);
      if (!response) {
        dialPlan.mainVoiceId = previous;
      }
    }
    dialPlan.reset();
  }

  void _updateOptionVoice(DialPlanModel dialPlan) async {
    final previous = dialPlan.optionVoiceId;
    dialPlan.optionVoiceId =
        await context.push<AudioModel>(AppRoutes.selectAudio.path);
    if (dialPlan.optionVoiceId != null) {
      final response = await _saveChanges(dialPlan);
      if (!response) {
        dialPlan.optionVoiceId = previous;
      }
    }
    dialPlan.reset();
  }

  void _updateNameSpell({
    int? value,
    required DialPlanModel dialPlan,
  }) async {
    final previous = dialPlan.nameSpell;
    dialPlan.nameSpell = value;
    final response = await _saveChanges(dialPlan);
    if (!response) {
      dialPlan.nameSpell = previous;
    }
    setState(() {});
  }

  void _addContacts() async {
    final cat1Filter = <String>[];
    final cat2Filter = <String>[];
    final cat3Filter = <String>[];
    final cat4Filter = <String>[];
    final cat5Filter = <String>[];
    await showModalBottomSheet(
      context: context,
      isDismissible: true,
      constraints: BoxConstraints(
        maxWidth: context.sw() - 20,
        minWidth: context.sw() - 20,
      ),
      builder: (context) {
        return ContactsFilter(
          cat1Filter: cat1Filter,
          cat2Filter: cat2Filter,
          cat3Filter: cat3Filter,
          cat4Filter: cat4Filter,
          cat5Filter: cat5Filter,
          setState: (fn) async {
            if (cat1Filter.isNotEmpty ||
                cat2Filter.isNotEmpty ||
                cat3Filter.isNotEmpty ||
                cat4Filter.isNotEmpty ||
                cat5Filter.isNotEmpty) {
              try {
                final response =
                    await locator<ApiClient>().addContactsToCampaign(
                  campaignId: _campaignDetail!.id!,
                  category1: cat1Filter,
                  category2: cat2Filter,
                  category3: cat3Filter,
                  category4: cat4Filter,
                  category5: cat5Filter,
                );
                if (response.isSuccess) {
                  _campaignDetail!.contactCount = response.data;
                  setState(() {});
                  if (mounted) {
                    QuickAlert.show(
                      context: context,
                      width: 200,
                      type: QuickAlertType.success,
                      text: "Contacts added successfully",
                    );
                  }
                } else {
                  if (mounted) {
                    QuickAlert.show(
                      context: context,
                      width: 200,
                      type: QuickAlertType.error,
                      text: "Unable to add contacts to campaign",
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  QuickAlert.show(
                    context: context,
                    width: 200,
                    type: QuickAlertType.error,
                    text: e.toString(),
                  );
                }
              }
            }
          },
          confirmText: "Confirm",
        );
      },
    );
  }

  void _changeStatus(int status) async {
    context.read<HudProvider>().showProgress();
    final previous = _campaignDetail!.status;
    _campaignDetail!.status = status;
    final response = await locator<ApiClient>().updateCampaignStatus(
      campaignId: _campaignDetail!.id!,
      status: _campaignDetail!.status!,
    );
    if (!response.isSuccess) {
      _campaignDetail!.status = previous;
    }
    setState(() {});
    if (mounted) {
      context.read<HudProvider>().hideProgress();
      QuickAlert.show(
        context: context,
        width: 200,
        type:
            response.isSuccess ? QuickAlertType.success : QuickAlertType.error,
        text: response.message,
      );
    }
  }

  void _selectHosts() {
    generalDialog(
      context: context,
      title: const Text("Select Machine For Campaign"),
      content: _buildHostList(),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text("Close"),
        ),
        ElevatedButton(
          onPressed: _startCampaign,
          child: const Text("Start Now"),
        ),
      ],
    );
  }

  Widget _buildHostList() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _campaignDetail!.hosts.map((host) {
        return StatefulBuilder(
          builder: (context, setState) {
            return ListTile(
              title: Text(host.host!),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CupertinoSwitch(
                    value: host.status == 1,
                    onChanged: (v) async {
                      final previousValue = host.status;
                      host.status = v ? 1 : 0;
                      // setState(() {});
                      final response =
                          await locator<ApiClient>().updateActiveCampaignHost(
                        campaignId: _campaignDetail!.id!,
                        hostId: host.id!,
                        status: host.status!,
                      );
                      if (!response.isSuccess) {
                        host.status = previousValue;
                        QuickAlert.show(
                          context: context,
                          width: 200,
                          type: QuickAlertType.error,
                          text: response.message,
                        );
                      }
                      setState(() {});
                    },
                  ),
                  const Gap(10),
                  if (host.status == 1)
                    ElevatedButton(
                      onPressed: () => _testDialPlan(host),
                      child: const Text('Test'),
                    ),
                ],
              ),
            );
          },
        );
      }).toList(),
    );
  }

  void _startCampaign() {
    final hasHosts =
        _campaignDetail!.hosts.any((element) => element.status == 1);
    if (hasHosts) {
      context.pop();
      _changeStatus(1);
    } else {
      QuickAlert.show(
        context: context,
        width: 200,
        type: QuickAlertType.warning,
        text: "Please select at least one host",
      );
    }
  }

  void _testDialPlan(HostModel host) async {
    String? number;
    final formKey = GlobalKey<FormState>();
    generalDialog(
      context: context,
      content: Form(
        key: formKey,
        child: TextFormField(
          decoration: const InputDecoration(
            labelText: "Enter Number",
          ),
          keyboardType: TextInputType.phone,
          onChanged: (value) => number = value,
          validator: (v) {
            if (v!.isEmpty && v.length < 10) {
              return "Please enter a number";
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () async {
            if (!formKey.currentState!.validate()) {
              return;
            }
            final response = await locator<ApiClient>().checkSampleCall(
              campaignId: _campaignDetail!.id!.toString(),
              hostId: host.id!.toString(),
              phoneNumber: number!,
            );

            if (response.isSuccess) {
              context.pop();
              QuickAlert.show(
                context: context,
                width: 200,
                type: QuickAlertType.success,
                text: response.message,
              );
            } else {
              QuickAlert.show(
                context: context,
                width: 200,
                type: QuickAlertType.error,
                text: response.message,
              );
            }
          },
          child: const Text("Call Now"),
        ),
      ],
    );
  }
}

/// Corrections in api
/// 1. Add dialplan to R PI when activating host for campaign, call the save dialplan api
