import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../models/route_argument.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info/package_info.dart';
import '../models/address.dart';
import '../models/setting.dart';
import '../services/api/api_service.dart';

ValueNotifier<Setting> setting = new ValueNotifier(new Setting());
ValueNotifier<Address> myAddress = new ValueNotifier(new Address());
final navigatorKey = GlobalKey<NavigatorState>();
const APP_STORE_URL =
    'https://apps.apple.com/gb/app/sabek-partner/id1600324402?uo=2';
const PLAY_STORE_URL =
    'https://play.google.com/store/apps/details?id=ly.sabek.delivery';
class SettingRepository extends ApiService {
  static SettingRepository get instance => SettingRepository();

  Future<Setting> initSettings() async {
    Setting _setting;
    final String url = 'settings';
    await get(
      url,
      requireAuthorization: false,
    ).then((response) async {
      print('categories:${response.statusCode}');
      if (response.statusCode == 200) {
        if (json.decode(response.data)['data'] != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString(
              'settings', json.encode(json.decode(response.data)['data']));
          _setting = Setting.fromJSON(json.decode(response.data)['data']);
          if (prefs.containsKey('language')) {
            _setting.mobileLanguage!.value =
                Locale(prefs.getString('language')!, '');
          }
          _setting.brightness!.value =
          prefs.getBool('isDark') ?? false ? Brightness.dark : Brightness.light;
          setting.value = _setting;
          // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
          setting.notifyListeners();
        }
      }
    }).catchError((onError) async {
      print('error : ${onError} ${onError
          .toString()
          .isEmpty}');
    });
    return setting.value;
  }


  Future<dynamic> setCurrentLocation() async {
    var location = new Location();
    final whenDone = new Completer();
    Address _address = new Address();
    location.requestService().then((value) async {
      location.getLocation().then((_locationData) async {
        String _addressName = '';
        _address = Address.fromJSON({
          'address': _addressName,
          'latitude': _locationData.latitude,
          'longitude': _locationData.longitude
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('my_address', json.encode(_address.toMap()));
        whenDone.complete(_address);
      }).timeout(Duration(seconds: 10), onTimeout: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('my_address', json.encode(_address.toMap()));
        whenDone.complete(_address);
        return null;
      }).catchError((e) {
        whenDone.complete(_address);
      });
    });
    return whenDone.future;
  }

  Future<Address> changeCurrentLocation(Address _address) async {
    if (!_address.isUnknown()) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('delivery_address', json.encode(_address.toMap()));
    }
    return _address;
  }

  Future<Address> getCurrentLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
//  await prefs.clear();
    if (prefs.containsKey('my_address')) {
      myAddress.value =
          Address.fromJSON(json.decode(prefs.getString('my_address')!));
      return myAddress.value;
    } else {
      myAddress.value = Address.fromJSON({});
      return Address.fromJSON({});
    }
  }

  void setBrightness(Brightness brightness) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (brightness == Brightness.dark) {
      prefs.setBool("isDark", true);
      brightness = Brightness.dark;
    } else {
      prefs.setBool("isDark", false);
      brightness = Brightness.light;
    }
  }

  Future<void> setDefaultLanguage(String language) async {
    if (language != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', language);
    }
  }

  Future<String> getDefaultLanguage(String defaultLanguage) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('language')) {
      defaultLanguage = await prefs.getString('language')!;
    }
    return defaultLanguage;
  }

  Future<void> saveMessageId(String messageId) async {
    if (messageId != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('google.message_id', messageId);
    }
  }

  Future<String> getMessageId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.getString('google.message_id')!;
  }

  versionCheck(context) async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    double currentVersion = double.parse(
        info.version.trim().replaceAll(".", ""));
    Platform.isIOS
        ? {
      if (double.tryParse(setting.value.appVersionIOS!.replaceAll(".", ""))! >
          currentVersion)
        {
          if (setting.value.forceUpdateIOS!)
            Navigator.of(context).pushReplacementNamed('/ForceUpdate',
                arguments: RouteArgument(id: ''))
          else
            {
              Navigator.of(context).pushReplacementNamed('/ForceUpdate',
                  arguments: RouteArgument(id: '0'))
            }
        }
      else
        Navigator.of(context).pushReplacementNamed('/Pages', arguments: 0)
    }
        : {
      if (double.tryParse(
          setting.value.appVersionAndroid!.replaceAll(".", ""))! >
          currentVersion)
        {
          if (setting.value.forceUpdateAndroid!)
            Navigator.of(context).pushReplacementNamed('/ForceUpdate',
                arguments: RouteArgument(id: ''))
          else
            {
              Navigator.of(context).pushReplacementNamed('/ForceUpdate',
                  arguments: RouteArgument(id: '0'))
            }
        }
      else
        Navigator.of(context).pushReplacementNamed('/Pages', arguments: 0)
    };
  }

  launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}