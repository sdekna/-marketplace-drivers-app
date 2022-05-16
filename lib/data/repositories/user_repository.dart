import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/route_manager.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

import '../models/statistic.dart';
import '../models/user.dart';
import '../services/api/api_service.dart';
import 'auth_repository.dart';

class UserRepository extends ApiService {
  static UserRepository get instance => UserRepository();
  final box = Get.find<GetStorage>();

  Future<User> userProfile() async {
    dynamic responseBody;
    await get(
      'driver/profile',
    ).then((response) async {
      print('${response.statusCode}');
      print('${response.data}');
      if (response.statusCode == 200) {
        responseBody = User.fromJSON(response.data['data']);
        // save user data
      } else if (response.statusCode == 422) {
        //token = '442';
      }
    }).catchError((onError) async {
      print('error : ${onError} ${onError.toString().isEmpty}');
      responseBody = new User();
    });
    return responseBody;
  }

  Future<Statistics> driverStatistics() async {
    dynamic responseBody;
    await get(
      'driver/statistics',
    ).then((response) async {
      print('${response.statusCode}');
      print('${response.data}');
      if (response.statusCode == 200) {
        responseBody = Statistics.fromJson(response.data['data']);
        // save user data
      } else if (response.statusCode == 422) {
        //token = '442';
      }
    }).catchError((onError) async {
      print('error : ${onError} ${onError.toString().isEmpty}');

      responseBody = new Statistics();
    });
    return responseBody;
  }

  Future<bool> updateDriverAvailable(driverState) async {
    final String url = 'driver/update-status';
    bool state = false;
    await post(
      url,
      extraHeaders: {HttpHeaders.contentTypeHeader: 'application/json'},
      data: {'available': driverState},
    ).then((response) async {
      print('${response.statusCode}');
      print('${response.data}');
      state = await response.statusCode == 200;
    }).catchError((onError) async {
      print('error : ${onError} ${onError.toString().isEmpty}');
      state = await false;
    });
    return state;
  }

  Future<bool> updateImage({required XFile image}) async {
    bool? state = null;
    FormData formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        image.path,
        filename: basename(image.path),
      )
    });
    await post(
      'update-profile-image',
      extraHeaders: {HttpHeaders.contentTypeHeader: 'application/json'},
      data: formData,
    ).then((value) {
      if (value.statusCode == 201 || value.statusCode == 200) {
        state = true;
      }
    }).catchError((e) async {
      state = false;
      if (e is DioError) {
        if (e.type == DioErrorType.response) {
          Get.snackbar('حدث خطأ', 'فشل دفع الصورة حاول مجددا');
        }
      } else {
        throw e;
      }
    });
    return state ?? false;
  }

  Future<User> update(User user) async {
    final String url = 'driver/users/${user.id}';
    await post(
      url,
      extraHeaders: {HttpHeaders.contentTypeHeader: 'application/json'},
      data: user.toMap(),
    ).then((response) async {
      if (response.statusCode == 200) {
        AuthRepository.instance.setCurrentUser(response.data['data']);
        currentUser.value = User.fromJSON(response.data['data']);
      }
    }).catchError((onError) async {
      print('error : ${onError} ${onError.toString().isEmpty}');
      currentUser.value = new User();
    });
    return currentUser.value;
  }

  Future<bool> updatePassword(User user) async {
    dynamic responseBody;
    final String url = 'users/change_password';
    await post(
      url,
      extraHeaders: {HttpHeaders.contentTypeHeader: 'application/json'},
      data: user.toPasswordMap(),
    ).then((response) async {
      if (response.statusCode == 200) responseBody = true;
    }).catchError((onError) async {
      print('error : ${onError} ${onError.toString().isEmpty}');
      responseBody = false;
    });
    return responseBody;
  }
}
