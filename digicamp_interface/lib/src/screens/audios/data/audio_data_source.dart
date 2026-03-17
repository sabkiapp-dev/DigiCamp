import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:digicamp_interface/injection_container.dart';
import 'package:digicamp_interface/src/config/app_constants.dart';
import 'package:digicamp_interface/src/models/models.dart';
import 'package:digicamp_interface/src/utils/services/rest_api.dart';

class AudioDataSource extends DataGridSource {
  AudioDataSource({
    required this.context,
    required List<AudioModel> audios,
    this.pageSize = 20,
    this.query,
    this.status,
    required this.audioPlayer,
  }) {
    buildDataGridRow(audios: audios);
  }

  // Filters
  int page = 1;
  int pageSize;
  String? query;
  String? order;
  String? status;
  BuildContext context;
  final AudioPlayer audioPlayer;
  List<DataGridRow> dataGridRows = [];

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        if (dataGridCell.columnName == 'audio') {
          final audio = dataGridCell.value as AudioModel;
          audioPlayer.playerStateStream.listen((event) {
            if (event.processingState == ProcessingState.completed) {
              audio.isPlaying.value = false;
            }
          });
          bool isLoading = false;
          int length = 0;
          int position = 0;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (audio.path != null && audio.path!.isNotEmpty) ...[
                ValueListenableBuilder(
                  valueListenable: audio.isPlaying,
                  builder: (context, value, child) {
                    return StatefulBuilder(
                      builder: (context, setState) {
                        audioPlayer.playerStateStream.listen((event) {
                          if (event.processingState ==
                              ProcessingState.completed) {
                            length = 0;
                            position = 0;
                            audio.isPlaying.value = false;
                          }
                        });
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            StreamBuilder<Duration?>(
                              stream: audioPlayer.positionStream,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  position = snapshot.data!.inMilliseconds;
                                }
                                return CircularProgressIndicator(
                                  value: length != 0 && audio.isPlaying.value
                                      ? position / length.toDouble()
                                      : 0,
                                  strokeWidth: 3,
                                  backgroundColor: Colors.grey[300],
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                    Colors.blue,
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: isLoading
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : value
                                      ? const Icon(Icons.pause)
                                      : const Icon(Icons.play_arrow),
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      for (final a in dataGridRows) {
                                        final audio =
                                            a.getCells()[4].value as AudioModel;
                                        if (audio.isPlaying.value) {
                                          audio.isPlaying.value = false;
                                          await audioPlayer.pause();
                                        }
                                      }

                                      if (!audio.isPlaying.value) {
                                        isLoading = true;
                                        setState(() {});
                                        try {
                                          final len = await audioPlayer
                                              .setUrl(audio.path!);
                                          if (len != null) {
                                            position = 0;
                                            length = len.inMilliseconds;
                                          }
                                        } catch (e) {
                                          isLoading = false;
                                          setState(() {});
                                          return;
                                        }
                                        isLoading = false;
                                        setState(() {});
                                      }
                                      if (value) {
                                        audio.isPlaying.value = false;
                                        await audioPlayer.pause();
                                      } else {
                                        audio.isPlaying.value = true;
                                        await audioPlayer.play();
                                      }
                                    },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                const Gap(5),
                Text(
                  p.basename(
                    audio.path!.replaceAll(r'\', '/'),
                  ),
                ),
              ] else ...[
                const IconButton(
                  onPressed: null,
                  icon: Icon(
                    Icons.warning_outlined,
                    size: 18,
                  ),
                ),
                const Text(
                  'Invalid URL',
                ),
              ]
            ],
          );
        }
        if (dataGridCell.columnName == 'status') {
          final audio = dataGridCell.value as AudioModel;
          return UnconstrainedBox(
            child: ValueListenableBuilder(
              valueListenable: audio.status,
              builder: (context, value, child) {
                return CupertinoSwitch(
                  value: value == 1,
                  onChanged: (v) => _changeStatus(audio),
                );
              },
            ),
          );
        }
        if (dataGridCell.columnName == 'selection') {
          final audio = dataGridCell.value as AudioModel;
          return UnconstrainedBox(
            child: ElevatedButton(
              onPressed: () {
                context.pop(audio);
              },
              child: const Text("Select"),
            ),
          );
        }
        if (dataGridCell.columnName == 'action') {
          final audio = dataGridCell.value as AudioModel;
          return UnconstrainedBox(
            child: IconButton(
              onPressed: () {
                context.push(
                  Uri(
                    path: AppRoutes.addAudio.path,
                    queryParameters: audio.toQueryParams(),
                  ).toString(),
                );
              },
              icon: const Icon(Icons.edit),
            ),
          );
        }
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(16.0),
          child: Text(dataGridCell.value.toString()),
        );
      }).toList(),
    );
  }

  @override
  Future<bool> handlePageChange(int oldPageIndex, int newPageIndex) async {
    if (oldPageIndex == newPageIndex) {
      return super.handlePageChange(oldPageIndex, newPageIndex);
    }
    page = newPageIndex + 1;
    final response = await locator<ApiClient>().audios(
      page: page,
      pageSize: pageSize,
      query: query,
      order: order,
      status: status,
    );
    if (response.isSuccess) {
      buildDataGridRow(audios: response.data!.data!);
      notifyListeners();
    }
    return super.handlePageChange(oldPageIndex, newPageIndex);
  }

  void buildDataGridRow({required List<AudioModel> audios}) {
    dataGridRows = audios.map<DataGridRow>((audio) {
      return DataGridRow(
        cells: [
          if (GoRouterState.of(context).path == AppRoutes.selectAudio.path)
            DataGridCell<AudioModel>(
              columnName: 'selection',
              value: audio,
            ),
          DataGridCell<int>(
            columnName: 'id',
            value: audio.id,
          ),
          DataGridCell<String>(
            columnName: 'voice_name',
            value: audio.voiceName,
          ),
          DataGridCell<String>(
            columnName: 'voice_desc',
            value: audio.voiceDesc,
          ),
          DataGridCell<AudioModel>(
            columnName: 'audio',
            value: audio,
          ),
          if (GoRouterState.of(context).path != AppRoutes.selectAudio.path)
            DataGridCell<AudioModel>(
              columnName: 'status',
              value: audio,
            ),
          DataGridCell<AudioModel>(
            columnName: 'action',
            value: audio,
          ),
        ],
      );
    }).toList();
  }

  void customSort(String sort) async {
    order = sort;
    final response = await locator<ApiClient>().audios(
      page: page,
      pageSize: pageSize,
      query: query,
      order: order,
      status: status,
    );
    if (response.isSuccess) {
      buildDataGridRow(audios: response.data!.data!);
      notifyListeners();
    }
  }

  void _changeStatus(AudioModel audio) async {
    final previousValue = audio.status.value;
    audio.status.value = audio.status.value == 0 ? 1 : 0;
    final response = await locator<ApiClient>().updateAudioStatus(
      audioId: audio.id!,
      status: audio.status.value,
    );

    if (!response.isSuccess) {
      audio.status.value = previousValue;
    }
  }
}
