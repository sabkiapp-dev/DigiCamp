import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quickalert/quickalert.dart';
import 'package:digicamp_interface/src/models/models.dart';

class FreezedDialPlan extends StatefulWidget {
  const FreezedDialPlan({super.key, required this.dialPlan});
  final List<DialPlanModel> dialPlan;

  @override
  State<FreezedDialPlan> createState() => _FreezedDialPlanState();
}

class _FreezedDialPlanState extends State<FreezedDialPlan> {
  final _columns = [
    'Extension Id',
    'Main Voice',
    'Name Spell',
    'Option Voice',
    'DTMF 0',
    'DTMF 1',
    'DTMF 2',
    'DTMF 3',
    'DTMF 4',
    'DTMF 5',
    'DTMF 6',
    'DTMF 7',
    'DTMF 8',
    'DTMF 9',
    'Continue To',
    'SMS Template',
    'Send SMS After',
  ];

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _audioPlayer.playerStateStream.listen((event) {
      if (event.processingState == ProcessingState.completed) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.grey.shade100,
      child: DataTable(
        columns: _columns.map((column) {
          return DataColumn(
            label: Text(
              column,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        rows: widget.dialPlan.map((dialPlan) {
          final nameSpell = switch (dialPlan.nameSpell) {
            0 => 'No',
            1 => 'Male Voice',
            2 => 'Female Voice',
            _ => 'N/A',
          };
          return DataRow(
            cells: [
              DataCell(Text(dialPlan.extensionId.toString())),
              DataCell(AudioPlayerWidget(
                label: dialPlan.mainVoiceId?.voiceName,
                uri: dialPlan.mainVoiceId?.path,
              )),
              DataCell(Text(nameSpell)),
              DataCell(AudioPlayerWidget(
                label: dialPlan.optionVoiceId?.voiceName,
                uri: dialPlan.optionVoiceId?.path,
              )),
              DataCell(Text(
                dialPlan.dtmf0 != null ? 'Extension ${dialPlan.dtmf0}' : 'N/A',
              )),
              DataCell(Text(
                dialPlan.dtmf1 != null ? 'Extension ${dialPlan.dtmf1}' : 'N/A',
              )),
              DataCell(Text(
                dialPlan.dtmf2 != null ? 'Extension ${dialPlan.dtmf2}' : 'N/A',
              )),
              DataCell(Text(
                dialPlan.dtmf3 != null ? 'Extension ${dialPlan.dtmf3}' : 'N/A',
              )),
              DataCell(Text(
                dialPlan.dtmf4 != null ? 'Extension ${dialPlan.dtmf4}' : 'N/A',
              )),
              DataCell(Text(
                dialPlan.dtmf5 != null ? 'Extension ${dialPlan.dtmf5}' : 'N/A',
              )),
              DataCell(Text(
                dialPlan.dtmf6 != null ? 'Extension ${dialPlan.dtmf6}' : 'N/A',
              )),
              DataCell(Text(
                dialPlan.dtmf7 != null ? 'Extension ${dialPlan.dtmf7}' : 'N/A',
              )),
              DataCell(Text(
                dialPlan.dtmf8 != null ? 'Extension ${dialPlan.dtmf8}' : 'N/A',
              )),
              DataCell(Text(
                dialPlan.dtmf9 != null ? 'Extension ${dialPlan.dtmf9}' : 'N/A',
              )),
              DataCell(Text(
                dialPlan.continueTo != null
                    ? 'Extension ${dialPlan.continueTo}'
                    : 'N/A',
              )),
              DataCell(Text(dialPlan.templateId?.templateName ?? 'N/A')),
              DataCell(Text(dialPlan.smsAfter.toString())),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class AudioPlayerWidget extends StatefulWidget {
  const AudioPlayerWidget({
    super.key,
    required this.label,
    required this.uri,
  });
  final String? label;
  final String? uri;

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.uri != null) {
      _audioPlayer
          .setAudioSource(AudioSource.uri(Uri.parse(widget.uri!)))
          .then((value) {
        _isInitialized = true;
      });
      _audioPlayer.playerStateStream.listen((event) {
        if (event.processingState == ProcessingState.completed) {
          setState(() {
            _isPlaying = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _audioPlayer.pause();
    _audioPlayer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: widget.uri != null
              ? () async {
                  if (!_isInitialized) {
                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.warning,
                      title: 'Audio is not initialized',
                    );
                    return;
                  }
                  if (_isPlaying) {
                    setState(() {
                      _isPlaying = false;
                    });
                    await _audioPlayer.pause();
                  } else {
                    setState(() {
                      _isPlaying = true;
                    });
                    await _audioPlayer.play();
                  }
                }
              : null,
          icon: widget.uri != null
              ? _isPlaying
                  ? const Icon(Icons.pause)
                  : const Icon(Icons.play_arrow)
              : const Icon(Icons.warning_outlined),
        ),
        Text(widget.label ?? 'N/A'),
      ],
    );
  }
}
