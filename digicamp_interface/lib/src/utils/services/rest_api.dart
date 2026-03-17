import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:digicamp_interface/src/models/models.dart';
import 'package:digicamp_interface/src/utils/extensions/response_extension.dart';

/// Signature for the authentication token provider.
typedef TokenProvider = Future<String?> Function();

class ApiClient {
  ApiClient({
    required TokenProvider tokenProvider,
    Client? httpClient,
    required String? baseUrl,
  }) : this._(
          baseUrl: baseUrl ?? 'localhost:8000',
          httpClient: httpClient,
          tokenProvider: tokenProvider,
        );

  /// Api client constructor
  ApiClient._({
    required String baseUrl,
    required TokenProvider tokenProvider,
    Client? httpClient,
  })  : _baseUrl = baseUrl,
        _client = httpClient ?? Client(),
        _tokenProvider = tokenProvider;

  final String _baseUrl;
  final Client _client;
  final TokenProvider _tokenProvider;
  static const String _clientVersion = '';

  ///
  Uri _uri(
    String unencodedPath, [
    Map<String, dynamic>? queryParameters,
  ]) {
    // Use http for local development (localhost), https for production
    final isLocalhost = _baseUrl.contains('localhost') || _baseUrl.contains('127.0.0.1');
    if (isLocalhost) {
      return Uri.http(
        _baseUrl,
        _clientVersion + unencodedPath,
        queryParameters,
      );
    }
    return Uri.https(
      _baseUrl,
      _clientVersion + unencodedPath,
      queryParameters,
    );
  }

  //
  Future<Data<TokenModel>> signIn({
    required String mobileNumber,
    required String password,
  }) async {
    final Uri url = _uri('/sign_in');
    try {
      final body = {
        "mobile_number": mobileNumber,
        "password": password,
      };
      final Response response = await _client.post(
        url,
        body: json.encode(body),
        headers: await _getRequestHeaders(),
      );
      final jsonResponse = response.decode;
      if (response.isSuccess) {
        return Data.fromResponse(response).copyWith(
          data: TokenModel.fromJson(jsonResponse),
        );
      }
      return Data.error(message: jsonResponse['message']);
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  //
  Future<Data> resetPassword({
    required String mobileNumber,
    required String password,
  }) async {
    final Uri url = _uri('/reset_password');
    try {
      final body = {
        "mobile_number": mobileNumber,
        "password": password,
      };
      final Response response = await _client.post(
        url,
        body: json.encode(body),
        headers: await _getRequestHeaders(),
      );
      final jsonResponse = response.decode;
      if (response.isSuccess) {
        return Data.fromResponse(response).copyWith(
          data: TokenModel.fromJson(jsonResponse),
        );
      }
      return Data.error(message: jsonResponse['message']);
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  //
  Future<Data> changeHost({
    required String mobileNumber,
    required String host,
  }) async {
    final Uri url = _uri('/change_host');
    try {
      final body = {
        "mobile_number": mobileNumber,
        "host": host,
      };
      final Response response = await _client.post(
        url,
        body: json.encode(body),
        headers: await _getRequestHeaders(),
      );
      final jsonResponse = response.decode;
      if (response.isSuccess) {
        return Data.fromResponse(response).copyWith(
          data: TokenModel.fromJson(jsonResponse),
        );
      }
      return Data.error();
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  //
  Future<Data> changeStatus({
    required int status,
    required String mobileNumber,
  }) async {
    final Uri url = _uri('/change_user_status');
    try {
      final body = {
        "status": status,
        "mobile_number": mobileNumber,
      };
      final Response response = await _client.post(
        url,
        body: json.encode(body),
        headers: await _getRequestHeaders(),
      );
      final jsonResponse = response.decode;
      if (response.isSuccess) {
        return Data.fromResponse(response).copyWith(
          message: jsonResponse["message"],
        );
      }
      return Data.error(message: jsonResponse['message']);
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  //
  Future<Data> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final Uri url = _uri('/change_password');
    try {
      final body = {
        "old_password": oldPassword,
        "new_password": newPassword,
      };
      final Response response = await _client.post(
        url,
        body: json.encode(body),
        headers: await _getRequestHeaders(),
      );
      final jsonResponse = response.decode;
      if (response.isSuccess) {
        return Data.fromResponse(response).copyWith(
          message: jsonResponse["message"],
        );
      }
      return Data.error(message: jsonResponse['message']);
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  //
  Future<Data> createUser({
    required String name,
    required String mobileNumber,
    required String password,
  }) async {
    final Uri url = _uri('/register');
    try {
      final body = {
        "name": name,
        "mobile_number": mobileNumber,
        "password": password,
        "is_superuser": false,
        "status": "1",
      };
      final Response response = await _client.post(
        url,
        body: json.encode(body),
        headers: await _getRequestHeaders(),
      );
      final jsonResponse = response.decode;
      if (response.isSuccess) {
        return Data.fromResponse(response).copyWith(
          data: jsonResponse["message"],
        );
      }
      return Data.error(message: jsonResponse['message']);
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  //
  Future<Data<CampaignModel>> addCampaign({
    required String name,
    required String? description,
    required int campaignPriority,
    required String language,
    required int maxCallCutTime,
    required String startDate,
    required String endDate,
    required String startTime,
    required String endTime,
    required int allowRepeat,
  }) async {
    final Uri url = _uri('/add_campaign');
    try {
      final body = {
        "name": name,
        "description": description,
        "campaign_priority": campaignPriority,
        "language": language,
        "call_cut_time": maxCallCutTime,
        "start_date": startDate,
        "end_date": endDate,
        "start_time": startTime,
        "end_time": endTime,
        "allow_repeat": allowRepeat,
      };
      final Response response = await _client.post(
        url,
        body: json.encode(body),
        headers: await _getRequestHeaders(),
      );
      final jsonResponse = response.decode;
      if (response.isSuccess) {
        return Data.fromResponse(response).copyWith(
          message: jsonResponse['message'],
          data: CampaignModel.fromJson(jsonResponse['data']),
        );
      }
      return Data.error();
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  //
  Future<Data> updateCampaign({
    required int id,
    required String name,
    required String? description,
    required int maxCallCutTime,
    required int campaignPriority,
    required String language,
    required String startDate,
    required String endDate,
    required String startTime,
    required String endTime,
    required int allowRepeat,
  }) async {
    final Uri url = _uri('/update_campaign');
    try {
      final body = {
        "id": id,
        "name": name,
        "description": description,
        "call_cut_time": maxCallCutTime,
        "campaign_priority": campaignPriority,
        "language": language,
        "start_date": startDate,
        "end_date": endDate,
        "start_time": startTime,
        "end_time": endTime,
        "allow_repeat": allowRepeat,
      };
      final Response response = await _client.put(
        url,
        body: json.encode(body),
        headers: await _getRequestHeaders(),
      );
      final jsonResponse = response.decode;
      if (response.isSuccess) {
        return Data.fromResponse(response).copyWith(
          message: jsonResponse['message'],
        );
      }
      return Data.error();
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  //
  Future<Data<List<RefUserModel>>> getReferredUsers() async {
    final Uri url = _uri('/get_referred_users');
    try {
      final Response response = await _client.get(
        url,
        headers: await _getRequestHeaders(),
      );
      final jsonResponse = response.decode;
      if (response.isSuccess) {
        return Data.fromResponse(response).copyWith(
          data: RefUserModel.fromMapList(jsonResponse),
        );
      }
      return Data.error(message: jsonResponse['message']);
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  //
  Future<Data<CampaignResponse>> campaigns({
    String? query,
    String? order,
    int? page,
    int? pageSize,
  }) async {
    final Uri url = _uri('/campaigns', {
      if (query != null) 'search': query,
      if (order != null) 'order': order,
      if (page != null) 'page': page.toString(),
      if (pageSize != null) 'page_size': pageSize.toString(),
    });
    try {
      final Response response = await _client.get(
        url,
        headers: await _getRequestHeaders(),
      );
      final jsonResponse = response.decode;
      if (response.isSuccess) {
        return Data.fromResponse(response).copyWith(
          data: CampaignResponse.fromJson(jsonResponse),
        );
      }
      return Data.error();
    } catch (exception) {
      print(exception);
      return Data.fromException(exception);
    }
  }

  //
  Future<Data<SmsResponseModel>> getSMSTemplates({
    String? query,
    String? order,
    int? page,
    int? pageSize,
    String? status,
  }) async {
    final Uri url = _uri('/get_sms_template', {
      if (query != null) 'query': query,
      if (order != null) 'order': order,
      if (page != null) 'page': page.toString(),
      if (pageSize != null) 'page_size': pageSize.toString(),
      if (status != null) 'status': status,
    });
    try {
      final Response response = await _client.get(
        url,
        headers: await _getRequestHeaders(),
      );
      final jsonResponse = response.decode;
      if (response.isSuccess) {
        return Data.fromResponse(response).copyWith(
          data: SmsResponseModel.fromJson(jsonResponse),
        );
      }
      return Data.error();
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  //
  Future<Data<AudioResponseModel>> audios({
    String? query,
    String? order,
    int? page,
    int? pageSize,
    String? status,
  }) async {
    final Uri url = _uri('/voices', {
      if (query != null) 'search': query,
      if (order != null) 'order': order,
      if (page != null) 'page': page.toString(),
      if (pageSize != null) 'page_size': pageSize.toString(),
      if (status != null) 'status': status,
    });
    try {
      final Response response = await _client.get(
        url,
        headers: await _getRequestHeaders(),
      );
      final jsonResponse = response.decode;
      if (response.isSuccess) {
        return Data.fromResponse(response).copyWith(
          data: AudioResponseModel.fromJson(jsonResponse),
        );
      }
      return Data.error();
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  //
  Future<Data<CampaignModel>> campaignDetail(int campaignId) async {
    final Uri url = _uri('/campaign_detail/$campaignId');
    try {
      final Response response = await _client.get(
        url,
        headers: await _getRequestHeaders(),
      );
      if (response.isSuccess) {
        final jsonResponse = response.decode;
        return Data.fromResponse(response).copyWith(
          data: CampaignModel.fromJson(jsonResponse),
        );
      }
      return Data.error();
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  //
  Future<Data> updateCampaignAudio({
    required int campaignId,
    int? noKeyAudio,
    int? wrongKeyAudio,
  }) async {
    final Uri url = _uri('/update_campaign_audio');
    try {
      final Response response = await _client.post(
        url,
        body: json.encode({
          'campaign_id': "$campaignId",
          if (noKeyAudio != null) 'no_key_voice': "$noKeyAudio",
          if (wrongKeyAudio != null) 'wrong_key_voice': "$wrongKeyAudio",
        }),
        headers: await _getRequestHeaders(),
      );
      if (response.isSuccess) {
        return Data.fromResponse(response);
      }
      return Data.error();
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  //
  Future<Data<CategoriesModel>> getUniqueCategories({
    List<String> category1 = const [],
    List<String> category2 = const [],
    List<String> category3 = const [],
    List<String> category4 = const [],
    List<String> category5 = const [],
  }) async {
    final Uri url = _uri('/get_unique_categories');
    final body = {
      "category_1": category1,
      "category_2": category2,
      "category_3": category3,
      "category_4": category4,
      "category_5": category5,
    };
    try {
      final Response response = await _client.post(
        url,
        headers: await _getRequestHeaders(),
        body: json.encode(body),
      );
      final jsonResponse = response.decode;
      if (response.isSuccess) {
        return Data.fromResponse(response).copyWith(
          data: CategoriesModel.fromJson(jsonResponse),
        );
      }
      return Data.error();
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  // Get all contacts
  Future<Data<ContactsResponse>> contacts({
    int? page,
    int? pageSize,
    String? query,
    List<String>? category1,
    List<String>? category2,
    List<String>? category3,
    List<String>? category4,
    List<String>? category5,
  }) async {
    final queryParams = <String, String>{
      if (page != null) 'page': page.toString(),
      if (pageSize != null) 'page_size': pageSize.toString(),
    };
    final Uri url = _uri('/contacts', queryParams);
    final body = {
      if (query != null && query.isNotEmpty) 'query': query,
      if (category1 != null && category1.isNotEmpty) 'category_1': category1,
      if (category2 != null && category2.isNotEmpty) 'category_2': category2,
      if (category3 != null && category3.isNotEmpty) 'category_3': category3,
      if (category4 != null && category4.isNotEmpty) 'category_4': category4,
      if (category5 != null && category5.isNotEmpty) 'category_5': category5,
    };
    try {
      final Response response = await _client.post(
        url,
        headers: await _getRequestHeaders(),
        body: json.encode(body),
      );
      final jsonResponse = response.decode;
      if (response.isSuccess) {
        return Data.fromResponse(response).copyWith(
          data: ContactsResponse.fromJson(jsonResponse),
        );
      }
      return Data.error();
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  // Add contacts
  Future<Data> addContacts({
    required List<ContactsModel> contacts,
  }) async {
    final Uri url = _uri('/add_contacts');
    try {
      final Response response = await _client.post(
        url,
        headers: await _getRequestHeaders(),
        body: json.encode(
          contacts.map((contact) => contact.toRestJson()).toList(),
        ),
      );
      final jsonResponse = response.decode;
      if (response.isSuccess) {
        return Data.fromResponse(response).copyWith(
          message: jsonResponse["message"],
          data: jsonResponse,
        );
      }
      return Data.error();
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  // Delete contacts
  Future<Data> deleteContacts({
    required List<String> contacts,
  }) async {
    final Uri url = _uri('/delete_contacts');
    try {
      final Response response = await _client.post(
        url,
        headers: await _getRequestHeaders(),
        body: json.encode({"phone_numbers": contacts}),
      );
      final jsonResponse = response.decode;
      if (response.isSuccess) {
        return Data.fromResponse(response).copyWith(
          message: jsonResponse["message"],
        );
      }
      return Data.error();
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  //
  Future<Data> addAudio({
    required String audioName,
    required String audioDescription,
    required Uint8List bytes,
    required String fileName,
  }) async {
    final Uri url = _uri('/add_audio');
    try {
      final body = {
        'voice_name': audioName,
        'voice_desc': audioDescription,
      };

      final headers = {
        HttpHeaders.authorizationHeader: 'Bearer ${await _tokenProvider()}',
        HttpHeaders.contentTypeHeader: 'multipart/form-data',
        HttpHeaders.acceptHeader: 'application/json',
      };

      var request = MultipartRequest('POST', url);
      request.fields.addAll(body);
      request.files.add(
        MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName,
          contentType: MediaType('audio', 'mpeg'),
        ),
      );
      request.headers.addAll(headers);

      StreamedResponse response = await _client.send(request);

      final jsonString = await response.stream.bytesToString();
      final jsonResponse = json.decode(jsonString);

      if (response.statusCode == 200) {
        return Data(
          statusCode: 200,
          message: jsonResponse["message"],
        );
      }
      return Data.error(message: jsonResponse['message']);
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  //
  Future<Data> addSMSTemplate({
    required String? templateName,
    required String? template,
  }) async {
    final Uri url = _uri('/add_sms_template');
    try {
      final body = {
        "template_name": templateName,
        "template": template,
      };
      final Response response = await _client.post(
        url,
        body: json.encode(body),
        headers: await _getRequestHeaders(),
      );
      final jsonResponse = response.decode;
      if (response.isSuccess) {
        return Data.fromResponse(response).copyWith(
          message: jsonResponse["message"],
        );
      }
      return Data.error(message: jsonResponse['message']);
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  //
  Future<Data> updateSMSTemplate({
    required int id,
    required String? name,
  }) async {
    final Uri url = _uri('/update_sms_template_name');
    try {
      final body = {
        "id": id,
        "name": name,
      };
      final Response response = await _client.post(
        url,
        body: json.encode(body),
        headers: await _getRequestHeaders(),
      );
      final jsonResponse = response.decode;
      if (response.isSuccess) {
        return Data.fromResponse(response).copyWith(
          message: jsonResponse["message"],
        );
      }
      return Data.error(message: jsonResponse['message']);
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  //
  Future<Data<SMSTemplateModel>> updateSMS({
    required int id,
    required String? templateName,
    required String? template,
  }) async {
    final Uri url = _uri('/update_sms');
    try {
      final body = {
        "id": id,
        "template_name": templateName,
        "template": template,
      };
      final Response response = await _client.patch(
        url,
        headers: await _getRequestHeaders(),
        body: json.encode(body),
      );
      final jsonResponse = response.decode;
      if (response.isSuccess) {
        return Data.fromResponse(response).copyWith(
          data: SMSTemplateModel.fromJson(jsonResponse),
        );
      }
      return Data.error(message: jsonResponse['message']);
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  //
  Future<Data> updateAudio({
    required int id,
    required String? name,
    required String? description,
  }) async {
    final Uri url = _uri('/update_voice');
    try {
      final body = {
        "id": id,
        "voice_name": name,
        "voice_desc": description,
      };
      final Response response = await _client.put(
        url,
        headers: await _getRequestHeaders(),
        body: json.encode(body),
      );
      if (response.isSuccess) {
        return Data.fromResponse(response);
      }
      return Data.error(message: response.decode['message']);
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  //
  Future<Data<DialPlanModel>> addDialPlan({
    required int? campaignId,
  }) async {
    final queryParameter = {
      "campaign_id": campaignId.toString(),
    };
    final Uri url = _uri('/add_dial_plan', queryParameter);
    try {
      final Response response = await _client.post(
        url,
        headers: await _getRequestHeaders(),
      );
      final jsonResponse = response.decode;
      if (response.isSuccess) {
        return Data.fromResponse(response).copyWith(
          data: DialPlanModel.fromJson(jsonResponse),
        );
      }
      return Data.error(message: jsonResponse['message']);
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  //
  Future<Data> updateDialPlan({
    required int id,
    required int? nameSpell,
    required int extensionId,
    required int campaignId,
    required int? mainVoice,
    required int? optionVoice,
    required int? dtmf0,
    required int? dtmf1,
    required int? dtmf2,
    required int? dtmf3,
    required int? dtmf4,
    required int? dtmf5,
    required int? dtmf6,
    required int? dtmf7,
    required int? dtmf8,
    required int? dtmf9,
    required int? continueTo,
    required int? templateId,
    required int? smsAfter,
  }) async {
    final Uri url = _uri('/update_dial_plan');
    try {
      final body = {
        "id": id,
        "name_spell": nameSpell,
        "extension_id": extensionId,
        "campaign_id": campaignId,
        "main_voice": mainVoice,
        "option_voice": optionVoice,
        "dtmf_0": dtmf0,
        "dtmf_1": dtmf1,
        "dtmf_2": dtmf2,
        "dtmf_3": dtmf3,
        "dtmf_4": dtmf4,
        "dtmf_5": dtmf5,
        "dtmf_6": dtmf6,
        "dtmf_7": dtmf7,
        "dtmf_8": dtmf8,
        "dtmf_9": dtmf9,
        "continue_to": continueTo,
        "template_id": templateId,
        "sms_after": smsAfter,
      };
      final Response response = await _client.patch(
        url,
        body: json.encode(body),
        headers: await _getRequestHeaders(),
      );
      final jsonResponse = response.decode;
      if (response.isSuccess) {
        return Data.fromResponse(response).copyWith(
          message: jsonResponse["message"],
        );
      }
      return Data.error(message: jsonResponse['message']);
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  //
  Future<Data> updateCampaignStatus({
    required int? campaignId,
    required int? status,
  }) async {
    final Uri url = _uri('/update_campaign_status');
    try {
      final data = {
        "id": campaignId,
        "status": status,
      };
      final Response response = await _client.post(
        url,
        body: json.encode(data),
        headers: await _getRequestHeaders(),
      );
      final jsonResponse = response.decode;
      if (response.isSuccess) {
        return Data.fromResponse(response).copyWith(
          message: jsonResponse["message"],
        );
      }
      return Data.error(message: jsonResponse['message']);
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  //
  Future<Data<List<DialPlanModel>>> dialPlans(int campaignId) async {
    final Uri url = _uri('/dial_plan/$campaignId');
    try {
      final Response response = await _client.get(
        url,
        headers: await _getRequestHeaders(),
      );
      final jsonResponse = response.decode;
      if (response.isSuccess) {
        return Data.fromResponse(response).copyWith(
          data: DialPlanModel.fromMapList(jsonResponse['data']),
        );
      }
      return Data.error(message: jsonResponse['message']);
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  //
  Future<Data> categoryContactsDelete({
    List<String> category1 = const [],
    List<String> category2 = const [],
    List<String> category3 = const [],
    List<String> category4 = const [],
    List<String> category5 = const [],
  }) async {
    final Uri url = _uri('/category_contacts_delete');
    try {
      final body = {
        "category_1": category1,
        "category_2": category2,
        "category_3": category3,
        "category_4": category4,
        "category_5": category5,
      };
      final Response response = await _client.post(
        url,
        body: json.encode(body),
        headers: await _getRequestHeaders(),
      );
      final jsonResponse = response.decode;
      if (response.isSuccess) {
        return Data.fromResponse(response).copyWith(
          message: jsonResponse["message"],
        );
      }
      return Data.error(message: jsonResponse['message']);
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  //
  Future<Data<int>> countCategoryContacts({
    List<String> category1 = const [],
    List<String> category2 = const [],
    List<String> category3 = const [],
    List<String> category4 = const [],
    List<String> category5 = const [],
  }) async {
    final Uri url = _uri('/count_category_contacts');
    try {
      final body = {
        "category_1": category1,
        "category_2": category2,
        "category_3": category3,
        "category_4": category4,
        "category_5": category5,
      };
      final Response response = await _client.post(
        url,
        body: json.encode(body),
        headers: await _getRequestHeaders(),
      );
      final jsonResponse = response.decode;
      if (response.isSuccess) {
        return Data.fromResponse(response).copyWith(
          message: jsonResponse["message"],
          data: jsonResponse["count"],
        );
      }
      return Data.error(message: jsonResponse['message']);
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  //
  Future<Data> addContactsGroup({
    String? category1,
    String? category2,
    String? category3,
    String? category4,
    String? category5,
    int? campaignId,
  }) async {
    final Uri url = _uri('/add_contact_group');
    try {
      final body = {
        "category_1": category1,
        "category_2": category2,
        "category_3": category3,
        "category_4": category4,
        "category_5": category5,
        "campaign_id": campaignId,
      };
      final Response response = await _client.post(
        url,
        body: json.encode(body),
        headers: await _getRequestHeaders(),
      );
      final jsonResponse = response.decode;
      if (response.isSuccess) {
        return Data.fromResponse(response).copyWith(
          message: jsonResponse["message"],
        );
      }
      return Data.error(message: jsonResponse['message']);
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  Future<Data<List<HostModel>>> getHostsByUser({required int userId}) async {
    final Uri url = _uri('/get_hosts/$userId');
    try {
      final Response response = await _client.get(
        url,
        headers: await _getRequestHeaders(),
      );
      final jsonResponse = response.decode;
      if (response.isSuccess) {
        return Data.fromResponse(response).copyWith(
          data: HostModel.fromMapList(jsonResponse),
        );
      }
      return Data.fromResponse(response);
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  Future<Data<List<HostModel>>> getHosts({required int userId}) async {
    final Uri url = _uri('/get_hosts/$userId');
    try {
      final Response response = await _client.get(
        url,
        headers: await _getRequestHeaders(),
      );
      final jsonResponse = response.decode;
      if (response.isSuccess) {
        return Data.fromResponse(response).copyWith(
          data: HostModel.fromMapList(jsonResponse),
        );
      }
      return Data.error(message: jsonResponse['message']);
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  Future<Data<HostModel>> addHost({
    required int userId,
    required String host,
    required String systemPassword,
    required int priority,
    required int allowSms,
  }) async {
    final Uri url = _uri('/user_host');
    try {
      final body = {
        "user_id": userId,
        "host": host,
        "system_password": systemPassword,
        "priority": priority,
        "allow_sms": allowSms,
      };
      final Response response = await _client.post(
        url,
        headers: await _getRequestHeaders(),
        body: json.encode(body),
      );
      final jsonResponse = response.decode;
      if (response.isSuccess) {
        return Data.fromResponse(response).copyWith(
          data: HostModel.fromJson(jsonResponse),
        );
      }
      return Data.error(message: jsonResponse['message']);
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  Future<Data> removeHost({
    required int hostId,
  }) async {
    final Uri url = _uri('/delete_host/$hostId');
    try {
      final Response response = await _client.delete(
        url,
        headers: await _getRequestHeaders(),
      );
      if (response.isSuccess) {
        return Data.fromResponse(response);
      }
      return Data.error(message: response.decode['message']);
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  Future<Data> editHost(
      {required int hostId,
      required String host,
      required String systemPassword,
      required int priority,
      required int allowSms}) async {
    final Uri url = _uri('/edit_host/$hostId');
    try {
      final body = {
        "host": host,
        "system_password": systemPassword,
        "priority": priority,
        "allow_sms": allowSms,
      };
      final Response response = await _client.put(
        url,
        headers: await _getRequestHeaders(),
        body: json.encode(body),
      );
      final jsonResponse = response.decode;
      if (response.isSuccess) {
        return Data.fromResponse(response);
      }
      return Data.error(message: jsonResponse['message']);
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  Future<Data> changeHostStatus({
    required int hostId,
    required int status,
  }) async {
    final Uri url = _uri(
      '/change_host_status',
      {
        "host_id": hostId.toString(),
        "status": status.toString(),
      },
    );
    try {
      final Response response = await _client.put(
        url,
        headers: await _getRequestHeaders(),
      );
      final jsonResponse = response.decode;
      if (response.isSuccess) {
        return Data.fromResponse(response);
      }
      return Data.error(message: jsonResponse['message']);
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  Future<Data<(String, String)>> getUserToken({
    required int userId,
  }) async {
    final Uri url = _uri('/get_user_token/$userId');
    try {
      final Response response = await _client.get(
        url,
        headers: await _getRequestHeaders(),
      );
      final jsonResponse = response.decode;
      if (response.isSuccess) {
        return Data.fromResponse(response).copyWith(
          data: (jsonResponse['token'], jsonResponse['name']),
        );
      }
      return Data.error(message: jsonResponse['message']);
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  Future<Data<MachineStatusModel>> machineStatus({
    required String? host,
    String? ussdForcefully,
    String? portForcefully,
  }) async {
    final Uri url = _uri('/get_all_machine_status', {
      if (host != null && host.isNotEmpty) 'host': host,
      if (ussdForcefully != null && ussdForcefully.isNotEmpty)
        'ussd_forcefully': ussdForcefully,
      if (portForcefully != null && portForcefully.isNotEmpty)
        'port_forcefully': portForcefully,
    });
    try {
      final Response response = await _client.get(
        url,
        headers: await _getRequestHeaders(),
      );
      final jsonResponse = response.decode;
      if (response.isSuccess) {
        return Data.fromResponse(response).copyWith(
          data: MachineStatusModel.fromJson(jsonResponse),
        );
      }
      return Data.error(message: jsonResponse['message']);
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  Future<Data> updateAudioStatus({
    required int audioId,
    required int status,
  }) async {
    final Uri url = _uri('/update_audio_status');
    try {
      final body = {
        "voice_id": audioId,
        "status": status,
      };
      final Response response = await _client.post(
        url,
        headers: await _getRequestHeaders(),
        body: json.encode(body),
      );
      if (response.isSuccess) {
        return Data.fromResponse(response);
      }
      return Data.error(message: response.decode['message']);
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  Future<Data<List<HostModel>>> activeHostStatus() async {
    final Uri url = _uri('/active_hosts_status');
    try {
      final Response response = await _client.get(
        url,
        headers: await _getRequestHeaders(),
      );
      if (response.isSuccess) {
        return Data.fromResponse(response).copyWith(
          data: HostModel.fromMapList(response.decode),
        );
      }
      return Data.error(message: response.decode['message']);
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  Future<Data> updateBulkSmsStatus({
    required int id,
    required int status,
  }) async {
    final Uri url = _uri('/update_sms_campaign_status');
    try {
      final body = {
        "id": id,
        "status": status,
      };
      final Response response = await _client.post(
        url,
        headers: await _getRequestHeaders(),
        body: json.encode(body),
      );
      if (response.isSuccess) {
        return Data.fromResponse(response);
      }
      return Data.error(message: response.decode['message']);
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  Future<Data> updateSMSTemplateStatus({
    required int templateId,
    required int status,
  }) async {
    final Uri url = _uri('/update_sms_template_status');
    try {
      final body = {
        "template_id": templateId,
        "status": status,
      };
      final Response response = await _client.post(
        url,
        headers: await _getRequestHeaders(),
        body: json.encode(body),
      );
      if (response.isSuccess) {
        return Data.fromResponse(response);
      }
      return Data.error(message: response.decode['message']);
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  Future<Data> addSmsCampaign(
      {required String name,
      required String description,
      required int priority,
      required String startTime,
      required String endTime,
      required String startDate,
      required String endDate,
      required int templateId}) async {
    final Uri url = _uri('/add_sms_campaign');
    try {
      final body = {
        "name": name,
        "description": description,
        "priority": priority,
        "start_time": startTime,
        "end_time": endTime,
        "start_date": startDate,
        "end_date": endDate,
        "template_id": templateId
      };
      final Response response = await _client.post(
        url,
        headers: await _getRequestHeaders(),
        body: json.encode(body),
      );
      if (response.isSuccess) {
        return Data.fromResponse(response);
      }
      return Data.error(message: response.decode['message']);
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  Future<Data<int>> addContactsToCampaign({
    required int campaignId,
    required List<String> category1,
    required List<String> category2,
    required List<String> category3,
    required List<String> category4,
    required List<String> category5,
  }) async {
    final Uri url = _uri('/add_contacts_to_campaign');
    try {
      final body = {
        "campaign_id": campaignId,
        "category_1": category1,
        "category_2": category2,
        "category_3": category3,
        "category_4": category4,
        "category_5": category5,
      };
      final Response response = await _client.post(
        url,
        headers: await _getRequestHeaders(),
        body: json.encode(body),
      );
      final jsonResponse = response.decode;
      if (response.isSuccess) {
        return Data.fromResponse(response).copyWith(
          data: jsonResponse['contacts_count'],
        );
      }
      return Data.error(message: jsonResponse['message']);
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  Future<Data> updateSmsCampaign({
    required int id,
    required String name,
    required String description,
    required int priority,
    required String startDate,
    required String endDate,
    required String startTime,
    required String endTime,
    required int templateId,
  }) async {
    final Uri url = _uri('/edit_sms_campaign');
    try {
      final body = {
        "id": id,
        "name": name,
        "description": description,
        "priority": priority,
        "start_time": startTime,
        "end_time": endTime,
        "start_date": startDate,
        "end_date": endDate,
        "template_id": templateId,
      };
      final Response response = await _client.post(
        url,
        headers: await _getRequestHeaders(),
        body: json.encode(body),
      );
      if (response.isSuccess) {
        return Data.fromResponse(response);
      }
      return Data.error(message: response.decode['message']);
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  //
  Future<Data<BulkSmsResponse>> bulkSms({
    String? query,
    String? order,
    int? page,
    int? pageSize,
    String? status,
  }) async {
    final Uri url = _uri('/get_sms_campaigns', {
      if (query != null) 'search': query,
      if (order != null) 'order': order,
      if (page != null) 'page': page.toString(),
      if (pageSize != null) 'page_size': pageSize.toString(),
      if (status != null) 'status': status,
    });
    try {
      final Response response = await _client.get(
        url,
        headers: await _getRequestHeaders(),
      );
      final jsonResponse = response.decode;
      if (response.isSuccess) {
        return Data.fromResponse(response).copyWith(
          data: BulkSmsResponse.fromJson(jsonResponse),
        );
      }
      return Data.error(message: jsonResponse['message']);
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  //
  Future<Data<String>> getApiKey() async {
    final Uri url = _uri('/get_api_key');
    try {
      final Response response = await _client.get(
        url,
        headers: await _getRequestHeaders(),
      );
      final jsonResponse = response.decode;
      if (response.isSuccess) {
        return Data.fromResponse(response).copyWith(
          data: jsonResponse['api_key'],
        );
      }
      return Data.error(message: jsonResponse['message']);
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  //
  Future<Data<String>> generateApiKey() async {
    final Uri url = _uri('/generate_api_key');
    try {
      final Response response = await _client.post(
        url,
        headers: await _getRequestHeaders(),
      );
      final jsonResponse = response.decode;
      if (response.isSuccess) {
        return Data.fromResponse(response).copyWith(
          data: jsonResponse['api_key'],
        );
      }
      return Data.error(message: jsonResponse['message']);
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  //
  Future<Data<List<ApiModel>>> getApiList() async {
    final Uri url = _uri('/get_api_docs');
    try {
      final Response response = await _client.get(
        url,
        headers: await _getRequestHeaders(),
      );
      final jsonResponse = response.decode;
      if (response.isSuccess) {
        return Data.fromResponse(response).copyWith(
          data: ApiModel.fromMapList(jsonResponse),
        );
      }
      return Data.error(message: jsonResponse['message']);
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  //
  Future<Data> updateActiveCampaignHost({
    required int campaignId,
    required int hostId,
    required int status,
  }) async {
    final Uri url = _uri('/update_active_campaign_host');
    try {
      final body = {
        "campaign_id": campaignId,
        "host_id": hostId,
        "status": status,
      };
      final Response response = await _client.post(
        url,
        headers: await _getRequestHeaders(),
        body: json.encode(body),
      );
      final jsonResponse = response.decode;
      if (response.isSuccess) {
        return Data.fromResponse(response);
      }
      return Data.error(message: jsonResponse['message']);
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  //
  Future<Data<CampaignReportResponseModel>> campaignReport({
    required int campaignId,
    int? page,
    int? pageSize,
  }) async {
    final Uri url = _uri('/campaign_detail_report');
    try {
      final body = {
        "campaign_id": campaignId,
        if (page != null) "page": page,
        if (pageSize != null) "page_size": pageSize,
      };
      final Response response = await _client.post(
        url,
        headers: await _getRequestHeaders(),
        body: json.encode(body),
      );
      final jsonResponse = response.decode;
      if (response.isSuccess) {
        return Data.fromResponse(response).copyWith(
          data: CampaignReportResponseModel.fromJson(jsonResponse),
        );
      }
      return Data.error(message: jsonResponse['message']);
    } catch (exception) {
      print(exception);
      return Data.fromException(exception);
    }
  }

  //
  Future<Data<CampaignSummaryModel>> campaignSummary({
    required int campaignId,
  }) async {
    final Uri url = _uri('/campaign_summary_report');
    try {
      final body = {
        "campaign_id": campaignId,
      };
      final Response response = await _client.post(
        url,
        headers: await _getRequestHeaders(),
        body: json.encode(body),
      );
      final jsonResponse = response.decode;
      if (response.isSuccess) {
        return Data.fromResponse(response).copyWith(
          data: CampaignSummaryModel.fromJson(jsonResponse['summary_report']),
        );
      }
      return Data.error(message: jsonResponse['message']);
    } catch (exception) {
      print(exception);
      return Data.fromException(exception);
    }
  }

  //
  Future<Data> addOperator({
    required int campaignAssociated,
    required String operator,
    required String description,
    required String? associatedNumber,
  }) async {
    final Uri url = _uri('/add_misscall_operator');
    try {
      final body = {
        "campaign_associated": campaignAssociated,
        "operator": operator,
        "description": description,
        if (associatedNumber != null) "associated_number": associatedNumber,
      };
      final Response response = await _client.post(
        url,
        headers: await _getRequestHeaders(),
        body: json.encode(body),
      );
      final jsonResponse = response.decode;
      if (response.isSuccess) {
        return Data.fromResponse(response);
      }
      return Data.error(message: jsonResponse['message']);
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  //
  Future<Data> checkSampleCall({
    required String campaignId,
    required String hostId,
    required String phoneNumber,
  }) async {
    final Uri url = _uri('/check_sample_call');
    try {
      final body = {
        "campaign_id": campaignId,
        "host_id": hostId,
        "phone_number": phoneNumber,
      };
      final Response response = await _client.post(
        url,
        headers: await _getRequestHeaders(),
        body: json.encode(body),
      );
      final jsonResponse = response.decode;
      if (response.isSuccess) {
        return Data.fromResponse(response);
      }
      return Data.error(message: jsonResponse['message']);
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  //
  Future<Data> updateOperatorStatus({
    required int id,
    required int status,
  }) async {
    final Uri url = _uri('/update_misscall_operator_status');
    try {
      final body = {
        "id": id,
        "status": status,
      };
      final Response response = await _client.post(
        url,
        headers: await _getRequestHeaders(),
        body: json.encode(body),
      );
      final jsonResponse = response.decode;
      if (response.isSuccess) {
        return Data.fromResponse(response);
      }
      return Data.error(message: jsonResponse['message']);
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  //
  Future<Data<MissCallResponseModel>> viewMissCalls({
    String? operator,
    int? page,
    int? pageSize,
    String? sort,
  }) async {
    final Uri url = _uri('/view_misscalls', {
      if (page != null) "page": page.toString(),
      if (pageSize != null) "page_size": pageSize.toString(),
    });
    try {
      final body = {
        if (operator != null) "operator": operator,
        if (sort != null) "sort": sort,
      };
      final Response response = await _client.post(
        url,
        headers: await _getRequestHeaders(),
        body: json.encode(body),
      );
      final jsonResponse = response.decode;
      if (response.isSuccess) {
        return Data.fromResponse(response).copyWith(
          data: MissCallResponseModel.fromJson(jsonResponse),
        );
      }
      return Data.error(message: jsonResponse['message']);
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  //
  Future<Data<List<OperatorModel>>> operators() async {
    final Uri url = _uri('/get_misscall_operators');
    try {
      final Response response = await _client.get(
        url,
        headers: await _getRequestHeaders(),
      );
      final jsonResponse = response.decode;
      if (response.isSuccess) {
        return Data.fromResponse(response).copyWith(
          data: OperatorModel.fromMapList(jsonResponse),
        );
      }
      return Data.error(message: jsonResponse['message']);
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  //
  Future<Data<String>> getHostPassword(String hostname) async {
    final queryParams = {
      'hostname': hostname,
    };
    final Uri url = _uri(
      '/get_host_password',
      queryParams,
    );
    try {
      final Response response = await _client.get(
        url,
        headers: await _getRequestHeaders(),
      );
      final jsonResponse = response.decode;
      if (response.isSuccess) {
        return Data.fromResponse(response).copyWith(
          data: jsonResponse['password'],
        );
      }
      return Data.error(message: jsonResponse['message']);
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  //
  Future<Data> editOperator({
    required String operator,
    required int campaignAssociated,
    required String description,
    String? associatedNumber,
    required int status,
  }) async {
    final body = {
      "operator": operator,
      "campaign_associated": campaignAssociated,
      "description": description,
      if (associatedNumber != null) "associated_number": associatedNumber,
      "status": status,
    };
    final Uri url = _uri('/edit_misscall_operator');
    try {
      final Response response = await _client.post(
        url,
        headers: await _getRequestHeaders(),
        body: json.encode(body),
      );
      final jsonResponse = response.decode;
      if (response.isSuccess) {
        return Data.fromResponse(response);
      }
      return Data.error(message: jsonResponse['message']);
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  //
  Future<Data> testBlockedSim({
    required String host,
    required int port,
    required int phoneNumber,
  }) async {
    final body = {
      "host": host,
      "port": port,
      "phone_number": phoneNumber,
    };
    final Uri url = _uri('/test_blocked_sim');
    try {
      final Response response = await _client.post(
        url,
        headers: await _getRequestHeaders(),
        body: json.encode(body),
      );
      final jsonResponse = response.decode;
      if (response.isSuccess) {
        return Data.fromResponse(response);
      }
      return Data.error(message: jsonResponse['message']);
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  //
  Future<Data<Uint8List>> downloadCampaignReport({
    required String type,
    required int campaignId,
  }) async {
    final params = {
      "type": type,
      "campaign_id": campaignId.toString(),
    };
    final Uri url = _uri('/download_campaign_report', params);
    try {
      final Response response = await _client.get(
        url,
        headers: await _getRequestHeaders(),
      );
      if (response.isSuccess) {
        return Data.fromResponse(response).copyWith(
          data: response.bodyBytes,
        );
      }
      return Data.error(message: response.decode['message']);
    } catch (exception) {
      return Data.fromException(exception);
    }
  }

  // Build request headers
  Future<Map<String, String>> _getRequestHeaders({String? contentType}) async {
    final token = await _tokenProvider();
    return <String, String>{
      HttpHeaders.contentTypeHeader: contentType ?? ContentType.json.value,
      HttpHeaders.acceptHeader: ContentType.json.value,
      if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token',
      // "ngrok-skip-browser-warning": "69420"
      // "Access-Control-Allow-Origin": "*",
      // "Access-Control-Allow-Credentials": "true",
      // "Access-Control-Allow-Headers":
      //     "X-PINGOTHER,Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
      // "Access-Control-Allow-Methods": "POST, OPTIONS"
    };
  }
}
