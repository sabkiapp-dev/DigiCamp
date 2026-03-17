class TokenModel {
  String? message;
  bool? isSuperuser;
  String? accessToken;

  TokenModel({this.message, this.isSuperuser, this.accessToken});

  factory TokenModel.fromJson(Map<String, dynamic> json) => TokenModel(
        message: json['message'] as String?,
        isSuperuser: json['is_superuser'] as bool?,
        accessToken: json['access_token'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'message': message,
        'is_superuser': isSuperuser,
        'access_token': accessToken,
      };
}
