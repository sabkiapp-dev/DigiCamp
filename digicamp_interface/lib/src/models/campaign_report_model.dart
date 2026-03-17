class CampaignReportResponseModel {
  int? totalPages;
  int? currentPage;
  List<CallReportModel>? data;

  CampaignReportResponseModel({
    this.totalPages,
    this.currentPage,
    this.data,
  });

  factory CampaignReportResponseModel.fromJson(Map<String, dynamic> json) {
    return CampaignReportResponseModel(
      totalPages: json['total_pages'] as int?,
      currentPage: json['current_page'] as int?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => CallReportModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CallReportModel {
  String? name;
  String? phoneNumber;
  String? sentStatus;
  String? sendDatetime;
  String? callThrough;
  int? duration;
  String? host;
  int? port;
  Map<String, int?> extensions = {};

  CallReportModel({
    this.name,
    this.phoneNumber,
    this.sentStatus,
    this.sendDatetime,
    this.callThrough,
    this.duration,
    this.host,
    this.port,
    this.extensions = const {},
  });

  factory CallReportModel.fromJson(Map<String, dynamic> json) {
    final extensions = <String, int?>{};
    for (final key in json.keys) {
      if (key.startsWith('extension_')) {
        extensions[key] = json[key] as int?;
      }
    }
    return CallReportModel(
      name: json['name'] as String?,
      phoneNumber: json['phone_number'] as String?,
      sentStatus: json['sent_status'] as String?,
      sendDatetime: json['sent_datetime'] as String?,
      callThrough: json['call_through'] as String?,
      duration: json['duration'] as int?,
      host: json['host'] as String?,
      port: json['port'] as int?,
      extensions: extensions,
    );
  }
}
