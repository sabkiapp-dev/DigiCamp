class ApiModel {
  String? name;
  String? url;
  String? method;
  String? description;

  ApiModel({this.name, this.url, this.method, this.description});

  factory ApiModel.fromJson(Map<String, dynamic> json) => ApiModel(
        name: json['name'] as String?,
        url: json['url'] as String?,
        method: json['method'] as String?,
        description: json['description'] as String?,
      );

  static List<ApiModel> fromMapList(List? json) {
    if (json == null) {
      return [];
    }
    return List<ApiModel>.from(
      json.map((v) => ApiModel.fromJson(v)),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'url': url,
        'method': method,
        'description': description,
      };
}
