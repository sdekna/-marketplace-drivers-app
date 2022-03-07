import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/values/colors.dart';
import '../../../routes/app_pages.dart';

class AppInterceptors extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (Get.find<GetStorage>().hasData('token')) {
      options.headers["Authorization"] = "Bearer " + Get.find<GetStorage>().read('token');
    }
    checkConnectivity().then((intenet) {
      if (intenet != null && intenet) {
        if (Get.find<GetStorage>().hasData('token')) {
          options.headers["Authorization"] = "Bearer " + Get.find<GetStorage>().read('token');
        }
      } else {
        Get.snackbar(
          'خطأ في الإنترنت ',
          'قم بتوصيل بالانترنت ثم حاول مره اخرى',
          duration: Duration(seconds: 5),
          backgroundColor: primaryColor.withOpacity(0.4),
          colorText: Colors.white,
        );
      }
    });

    super.onRequest(options, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    if (err.type == DioErrorType.response) {
      if(err.response?.statusCode == 422) {
        Get.snackbar('error', err.message);
      }else if(err.response?.statusCode == 401){
        Get.snackbar('error', err.message);
        // logout
      }
    }
    super.onError(err, handler);
  }

  @override
  Future<void> onResponse(Response response, ResponseInterceptorHandler handler) async {
    try{
      if (response.data['data'] is Map<String, dynamic>) {
        Map<String, dynamic> data = response.data['data'];
        print(data.containsKey('token'));
        print(data);
        if (data.containsKey('token')) {
          await Get.find<GetStorage>().write("token", data['token']);
          Get.offAllNamed(Routes.HOME);

        }
      }
    }catch(e){

    }
    super.onResponse(response, handler);
  }

  Future<bool> checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }
}

