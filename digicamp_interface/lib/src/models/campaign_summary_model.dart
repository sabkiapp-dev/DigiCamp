class CampaignSummaryModel {
  int totalCallsUnique;
  int answeredCallsUnique;
  int ongoingCalls;
  int unansweredCalls;
  int toBeDialed;
  int cancelledCalls;
  double? averageCallDurationAnswered;
  int callsDuration0To10;
  int callsDuration11To20;
  int callsDuration21To30;
  int callsDuration31To40;
  int callsDuration41To50;
  int callsDuration51To60;
  int callsDuration61To90;
  int callsDuration91To120;
  int callsDuration121Plus;
  Map<String, Map<String, int>> extensionsPressedRecent = {};

  CampaignSummaryModel({
    this.totalCallsUnique = 0,
    this.answeredCallsUnique = 0,
    this.ongoingCalls = 0,
    this.unansweredCalls = 0,
    this.toBeDialed = 0,
    this.cancelledCalls = 0,
    this.averageCallDurationAnswered,
    this.callsDuration0To10 = 0,
    this.callsDuration11To20 = 0,
    this.callsDuration21To30 = 0,
    this.callsDuration31To40 = 0,
    this.callsDuration41To50 = 0,
    this.callsDuration51To60 = 0,
    this.callsDuration61To90 = 0,
    this.callsDuration91To120 = 0,
    this.callsDuration121Plus = 0,
    this.extensionsPressedRecent = const {},
  });

  factory CampaignSummaryModel.fromJson(Map<String, dynamic> json) {
    final ext = <String, Map<String, int>>{};
    if (json['extensions_pressed_recent'] != null) {
      for (final key in json['extensions_pressed_recent'].keys) {
        ext[key] =
            Map<String, int>.from(json['extensions_pressed_recent'][key]);
      }
    }
    return CampaignSummaryModel(
      totalCallsUnique: json['total_calls_unique'] ?? 0,
      answeredCallsUnique: json['answered_calls_unique'] ?? 0,
      ongoingCalls: json['ongoing_calls'] ?? 0,
      unansweredCalls: json['unanswered_calls'] ?? 0,
      toBeDialed: json['to_be_dialed'] ?? 0,
      cancelledCalls: json['cancelled_calls'] ?? 0,
      averageCallDurationAnswered:
          json['average_call_duration_answered'] as double?,
      callsDuration0To10: json['calls_duration_0_to_10'] ?? 0,
      callsDuration11To20: json['calls_duration_11_to_20'] ?? 0,
      callsDuration21To30: json['calls_duration_21_to_30'] ?? 0,
      callsDuration31To40: json['calls_duration_31_to_40'] ?? 0,
      callsDuration41To50: json['calls_duration_41_to_50'] ?? 0,
      callsDuration51To60: json['calls_duration_51_to_60'] ?? 0,
      callsDuration61To90: json['calls_duration_61_to_90'] ?? 0,
      callsDuration91To120: json['calls_duration_91_to_120'] ?? 0,
      callsDuration121Plus: json['calls_duration_121_plus'] ?? 0,
      extensionsPressedRecent: ext,
    );
  }

  Map<String, dynamic> toJson() => {
        'total_calls_unique': totalCallsUnique,
        'answered_calls_unique': answeredCallsUnique,
        'ongoing_calls': ongoingCalls,
        'unanswered_calls': unansweredCalls,
        'to_be_dialed': toBeDialed,
        'cancelled_calls': cancelledCalls,
        'average_call_duration_answered': averageCallDurationAnswered,
        'calls_duration_0_to_10': callsDuration0To10,
        'calls_duration_11_to_20': callsDuration11To20,
        'calls_duration_21_to_30': callsDuration21To30,
        'calls_duration_31_to_40': callsDuration31To40,
        'calls_duration_41_to_50': callsDuration41To50,
        'calls_duration_51_to_60': callsDuration51To60,
        'calls_duration_61_to_90': callsDuration61To90,
        'calls_duration_91_to_120': callsDuration91To120,
        'calls_duration_121_plus': callsDuration121Plus,
        'extensions_pressed_recent': extensionsPressedRecent,
      };
}
