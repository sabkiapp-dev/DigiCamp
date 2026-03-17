import 'audio_response_model.dart';
import 'sms_response_model.dart';

class DialPlanModel {
  int? id;
  int? extensionId;
  int? campaign;
  int? _nameSpell;
  AudioModel? _mainVoiceId;
  AudioModel? _optionVoiceId;
  int? _dtmf0;
  int? _dtmf1;
  int? _dtmf2;
  int? _dtmf3;
  int? _dtmf4;
  int? _dtmf5;
  int? _dtmf6;
  int? _dtmf7;
  int? _dtmf8;
  int? _dtmf9;
  int? _continueTo;
  SMSTemplateModel? _templateId;
  int? _smsAfter;
  String? modifiedAt;
  String? createdAt;

  bool _modified = false;

  int? get nameSpell => _nameSpell;
  AudioModel? get mainVoiceId => _mainVoiceId;
  AudioModel? get optionVoiceId => _optionVoiceId;
  int? get dtmf0 => _dtmf0;
  int? get dtmf1 => _dtmf1;
  int? get dtmf2 => _dtmf2;
  int? get dtmf3 => _dtmf3;
  int? get dtmf4 => _dtmf4;
  int? get dtmf5 => _dtmf5;
  int? get dtmf6 => _dtmf6;
  int? get dtmf7 => _dtmf7;
  int? get dtmf8 => _dtmf8;
  int? get dtmf9 => _dtmf9;
  int? get continueTo => _continueTo;
  SMSTemplateModel? get templateId => _templateId;
  int? get smsAfter => _smsAfter;
  bool get modified => _modified;

  set nameSpell(int? value) {
    _nameSpell = value;
    _modified = true;
  }

  set mainVoiceId(AudioModel? value) {
    _mainVoiceId = value;
    _modified = true;
  }

  set optionVoiceId(AudioModel? value) {
    _optionVoiceId = value;
    _modified = true;
  }

  set dtmf0(int? value) {
    _dtmf0 = value;
    _continueTo = null;
    _modified = true;
  }

  set dtmf1(int? value) {
    _dtmf1 = value;
    _continueTo = null;
    _modified = true;
  }

  set dtmf2(int? value) {
    _dtmf2 = value;
    _continueTo = null;
    _modified = true;
  }

  set dtmf3(int? value) {
    _dtmf3 = value;
    _continueTo = null;
    _modified = true;
  }

  set dtmf4(int? value) {
    _dtmf4 = value;
    _continueTo = null;
    _modified = true;
  }

  set dtmf5(int? value) {
    _dtmf5 = value;
    _continueTo = null;
    _modified = true;
  }

  set dtmf6(int? value) {
    _dtmf6 = value;
    _continueTo = null;
    _modified = true;
  }

  set dtmf7(int? value) {
    _dtmf7 = value;
    _continueTo = null;
    _modified = true;
  }

  set dtmf8(int? value) {
    _dtmf8 = value;
    _continueTo = null;
    _modified = true;
  }

  set dtmf9(int? value) {
    _dtmf9 = value;
    _continueTo = null;
    _modified = true;
  }

  set continueTo(int? value) {
    _continueTo = value;
    _modified = true;
  }

  set templateId(SMSTemplateModel? value) {
    _templateId = value;
    _modified = true;
  }

  set smsAfter(int? value) {
    _smsAfter = value;
    _modified = true;
  }

  void reset() {
    _modified = false;
  }

  void clear() {
    _nameSpell = 0;
    _mainVoiceId = null;
    _optionVoiceId = null;
    _dtmf0 = null;
    _dtmf1 = null;
    _dtmf2 = null;
    _dtmf3 = null;
    _dtmf4 = null;
    _dtmf5 = null;
    _dtmf6 = null;
    _dtmf7 = null;
    _dtmf8 = null;
    _dtmf9 = null;
    _templateId = null;
    _smsAfter = null;
    _modified = true;
  }

  bool get hasOptions =>
      _dtmf0 != null ||
      _dtmf1 != null ||
      _dtmf2 != null ||
      _dtmf3 != null ||
      _dtmf4 != null ||
      _dtmf5 != null ||
      _dtmf6 != null ||
      _dtmf7 != null ||
      _dtmf8 != null ||
      _dtmf9 != null;

  List<int?> get options => [
        _dtmf0,
        _dtmf1,
        _dtmf2,
        _dtmf3,
        _dtmf4,
        _dtmf5,
        _dtmf6,
        _dtmf7,
        _dtmf8,
        _dtmf9,
      ];

  bool get isEmpty {
    return _mainVoiceId == null &&
        _optionVoiceId == null &&
        _dtmf0 == null &&
        _dtmf1 == null &&
        _dtmf2 == null &&
        _dtmf3 == null &&
        _dtmf4 == null &&
        _dtmf5 == null &&
        _dtmf6 == null &&
        _dtmf7 == null &&
        _dtmf8 == null &&
        _dtmf9 == null &&
        _templateId == null &&
        _smsAfter == null;
  }

  DialPlanModel({
    this.id,
    this.campaign,
    this.extensionId,
    int? nameSpell,
    AudioModel? mainVoiceId,
    AudioModel? optionVoiceId,
    int? dtmf0,
    int? dtmf1,
    int? dtmf2,
    int? dtmf3,
    int? dtmf4,
    int? dtmf5,
    int? dtmf6,
    int? dtmf7,
    int? dtmf8,
    int? dtmf9,
    SMSTemplateModel? templateId,
    int? smsAfter,
    this.modifiedAt,
    this.createdAt,
  })  : _nameSpell = nameSpell,
        _mainVoiceId = mainVoiceId,
        _optionVoiceId = optionVoiceId,
        _dtmf0 = dtmf0,
        _dtmf1 = dtmf1,
        _dtmf2 = dtmf2,
        _dtmf3 = dtmf3,
        _dtmf4 = dtmf4,
        _dtmf5 = dtmf5,
        _dtmf6 = dtmf6,
        _dtmf7 = dtmf7,
        _dtmf8 = dtmf8,
        _dtmf9 = dtmf9,
        _templateId = templateId,
        _smsAfter = smsAfter;

  static List<DialPlanModel> fromMapList(List? json) {
    if (json == null) {
      return [];
    }
    return List<DialPlanModel>.from(
      json.map((v) => DialPlanModel.fromJson(v)),
    );
  }

  factory DialPlanModel.fromJson(Map<String, dynamic> json) => DialPlanModel(
        id: json['id'] as int?,
        campaign: json['campaign'] as int?,
        nameSpell: json['name_spell'] as int?,
        extensionId: json['extension_id'] as int?,
        mainVoiceId: json['main_voice_id'] == null
            ? null
            : AudioModel.fromJson(
                json['main_voice_id'] as Map<String, dynamic>),
        optionVoiceId: json['option_voice_id'] == null
            ? null
            : AudioModel.fromJson(
                json['option_voice_id'] as Map<String, dynamic>),
        dtmf0: json['dtmf_0'] as int?,
        dtmf1: json['dtmf_1'] as int?,
        dtmf2: json['dtmf_2'] as int?,
        dtmf3: json['dtmf_3'] as int?,
        dtmf4: json['dtmf_4'] as int?,
        dtmf5: json['dtmf_5'] as int?,
        dtmf6: json['dtmf_6'] as int?,
        dtmf7: json['dtmf_7'] as int?,
        dtmf8: json['dtmf_8'] as int?,
        dtmf9: json['dtmf_9'] as int?,
        templateId: json['template_id'] == null
            ? null
            : SMSTemplateModel.fromJson(
                json['template_id'] as Map<String, dynamic>),
        smsAfter: json['sms_after'] as int?,
        modifiedAt: json['modified_at'] as String?,
        createdAt: json['created_at'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'campaign': campaign,
        'name_spell': nameSpell,
        'extension_id': extensionId,
        'main_voice_id': _mainVoiceId?.toJson(),
        'option_voice_id': _optionVoiceId?.toJson(),
        'dtmf_0': _dtmf0,
        'dtmf_1': _dtmf1,
        'dtmf_2': _dtmf2,
        'dtmf_3': _dtmf3,
        'dtmf_4': _dtmf4,
        'dtmf_5': _dtmf5,
        'dtmf_6': _dtmf6,
        'dtmf_7': _dtmf7,
        'dtmf_8': _dtmf8,
        'dtmf_9': _dtmf9,
        'template_id': _templateId?.toJson(),
        'sms_after': _smsAfter,
        'modified_at': modifiedAt,
        'created_at': createdAt,
      };

  /// Create copy with method which will copy from another DialPlanModel and return a new DialPlanModel
  DialPlanModel copyWith(DialPlanModel model) {
    return DialPlanModel(
      id: model.id ?? id,
      campaign: model.campaign ?? campaign,
      nameSpell: model.nameSpell ?? nameSpell,
      extensionId: model.extensionId ?? extensionId,
      mainVoiceId: model.mainVoiceId ?? mainVoiceId,
      optionVoiceId: model.optionVoiceId ?? optionVoiceId,
      dtmf0: model.dtmf0 ?? dtmf0,
      dtmf1: model.dtmf1 ?? dtmf1,
      dtmf2: model.dtmf2 ?? dtmf2,
      dtmf3: model.dtmf3 ?? dtmf3,
      dtmf4: model.dtmf4 ?? dtmf4,
      dtmf5: model.dtmf5 ?? dtmf5,
      dtmf6: model.dtmf6 ?? dtmf6,
      dtmf7: model.dtmf7 ?? dtmf7,
      dtmf8: model.dtmf8 ?? dtmf8,
      dtmf9: model.dtmf9 ?? dtmf9,
      templateId: model.templateId ?? templateId,
      smsAfter: model.smsAfter ?? smsAfter,
      modifiedAt: model.modifiedAt ?? modifiedAt,
      createdAt: model.createdAt ?? createdAt,
    );
  }
}
