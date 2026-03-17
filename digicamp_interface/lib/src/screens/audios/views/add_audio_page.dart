import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:digicamp_interface/injection_container.dart';
import 'package:digicamp_interface/src/providers/providers.dart';
import 'package:digicamp_interface/src/utils/services/rest_api.dart';

class AddAudioPage extends StatefulWidget {
  const AddAudioPage({super.key});

  @override
  State<AddAudioPage> createState() => _AddAudioPageState();
}

class _AddAudioPageState extends State<AddAudioPage> {
  final FilePicker _picker = FilePicker.platform;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();
  final TextEditingController _pathCtrl = TextEditingController();
  final ValueNotifier<bool> _isPlaying = ValueNotifier<bool>(false);
  Uint8List? _bytes;
  bool _isEditable = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final query = GoRouterState.of(context).uri.queryParameters;
      if (query.containsKey("id")) {
        _isEditable = true;
        final path = query["path"];
        _nameCtrl.text = query["voice_name"]!;
        _descriptionCtrl.text = query["voice_desc"]!;
        _pathCtrl.text = p.basename(
          path?.replaceAll(r'\', '/') ?? '',
        );
        if (path != null && path.isNotEmpty) {
          _audioPlayer.setAudioSource(
            AudioSource.uri(
              Uri.parse(query["path"]!),
            ),
          );
        }
        setState(() {});
      }
    });

    _audioPlayer.playerStateStream.listen((event) {
      if (event.processingState == ProcessingState.completed) {
        _isPlaying.value = false;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _audioPlayer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                hintText: "Audio Name",
              ),
              validator: _validate,
            ),
            const Gap(5),
            TextFormField(
              controller: _pathCtrl,
              readOnly: true,
              onTap: _isEditable
                  ? null
                  : () async {
                      final file = await _picker.pickFiles(
                        allowMultiple: false,
                        type: FileType.audio,
                      );

                      if (file != null && file.files.isNotEmpty) {
                        _pathCtrl.text = file.files.first.name;
                        _bytes = file.files.first.bytes;
                      }
                    },
              decoration: InputDecoration(
                hintText: "Audio File",
                prefixIcon: ValueListenableBuilder(
                  valueListenable: _pathCtrl,
                  builder: (context, name, child) {
                    if (name.text.isEmpty) {
                      return const SizedBox();
                    }
                    return ValueListenableBuilder(
                      valueListenable: _isPlaying,
                      builder: (context, value, child) {
                        return IconButton(
                          icon: value
                              ? const Icon(Icons.pause)
                              : const Icon(Icons.play_arrow),
                          onPressed: () async {
                            await _audioPlayer.setAudioSource(
                              ByteAudioSource(_bytes!),
                            );
                            if (value) {
                              _isPlaying.value = false;
                              await _audioPlayer.pause();
                            } else {
                              _isPlaying.value = true;
                              await _audioPlayer.play();
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              validator: _validate,
            ),
            const Gap(5),
            TextFormField(
              controller: _descriptionCtrl,
              decoration: const InputDecoration(
                hintText: "Description",
                contentPadding: EdgeInsets.all(10),
              ),
              validator: _validate,
              maxLines: 4,
            ),
            const Gap(5),
            ElevatedButton(
              onPressed: _isEditable ? _updateAudio : _uploadAudio,
              child: Text(_isEditable ? "Upload Audio" : "Add Audio"),
            )
          ],
        ),
      ),
    );
  }

  String? _validate(String? value) {
    if (value == null || value.isEmpty) {
      return "Required*";
    }
    return null;
  }

  void _uploadAudio() async {
    if (!_formKey.currentState!.validate()) {
      QuickAlert.show(
        context: context,
        width: 200,
        type: QuickAlertType.warning,
        text: "All fields are required",
      );
      return;
    }
    if (!(await _userConsent())) {
      return;
    }
    context.read<HudProvider>().showProgress();
    final response = await locator<ApiClient>().addAudio(
      audioName: _nameCtrl.text,
      audioDescription: _descriptionCtrl.text,
      bytes: _bytes!,
      fileName: _pathCtrl.text,
    );

    context.read<HudProvider>().hideProgress();
    if (response.isSuccess) {
      _nameCtrl.clear();
      _descriptionCtrl.clear();
      _pathCtrl.clear();
      _bytes = null;
      QuickAlert.show(
        context: context,
        width: 200,
        type: QuickAlertType.success,
        text: response.message,
      );
      setState(() {});
    } else {
      QuickAlert.show(
        context: context,
        width: 200,
        type: QuickAlertType.error,
        text: response.message,
      );
    }
  }

  void _updateAudio() async {
    if (!_formKey.currentState!.validate()) {
      QuickAlert.show(
        context: context,
        width: 200,
        type: QuickAlertType.warning,
        text: "All fields are required",
      );
      return;
    }

    context.read<HudProvider>().showProgress();
    final response = await locator<ApiClient>().updateAudio(
      id: int.parse(GoRouterState.of(context).uri.queryParameters["id"]!),
      name: _nameCtrl.text,
      description: _descriptionCtrl.text,
    );
    context.read<HudProvider>().hideProgress();

    if (response.isSuccess) {
      _nameCtrl.clear();
      _descriptionCtrl.clear();
      _pathCtrl.clear();
      QuickAlert.show(
        context: context,
        width: 200,
        type: QuickAlertType.success,
        text: response.message,
      );
      context.pop();
    } else {
      QuickAlert.show(
        context: context,
        width: 200,
        type: QuickAlertType.error,
        text: response.message,
      );
    }
  }

  Future<bool> _userConsent() async {
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: SizedBox(
          width: MediaQuery.of(context).size.width / 2,
          child: const Text.rich(
            TextSpan(
              text: "Are you sure, You want to add this audio file.\n\n",
              children: [
                TextSpan(
                  text:
                      "Warning: This action is non-reversible. Only Name & Description can be modified later.",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            child: const Text("Yes"),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

// Feed your own stream of bytes into the player
class ByteAudioSource extends StreamAudioSource {
  final List<int> bytes;
  ByteAudioSource(this.bytes);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= bytes.length;
    return StreamAudioResponse(
      sourceLength: bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(bytes.sublist(start, end)),
      contentType: 'audio/mpeg',
    );
  }
}
