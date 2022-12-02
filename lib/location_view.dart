import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart'
    show BMFMapSDK, BMF_COORD_TYPE;
import 'package:flutter_baidu_mapapi_base/src/map/bmf_models.dart';
import 'package:flutter_baidu_mapapi_map/flutter_baidu_mapapi_map.dart';
import 'package:flutter_bmflocation/flutter_bmflocation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationView extends StatefulWidget {
  const LocationView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MapRouteState();
  }
}

class MapRouteState extends State<LocationView> {
  late TextEditingController positionController;
  late LocationFlutterPlugin _locationPlugin;

  BaiduLocationIOSOption iosOption =
      BaiduLocationIOSOption(coordType: BMFLocationCoordType.gcj02);
  BaiduLocationAndroidOption androidOption =
      BaiduLocationAndroidOption(coordType: BMFLocationCoordType.gcj02);
  late BMFMapController _controller;
  late BaiduLocation _location;

  //周边信息
  List<BaiduPoiList> _poiList = [];

  @override
  void initState() {
    positionController = TextEditingController();
    _locationPlugin = LocationFlutterPlugin();
    _locationPlugin.setAgreePrivacy(true);
    _location = BaiduLocation();
    _locationPlugin.seriesLocationCallback(callback: (BaiduLocation result) {
      _location = result;
      _stopLocation();
      updatePosition();
    });
    _startLocation();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text(
            "选取地点",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.blue,
        ),
        body: _map(),
      ),
    );
  }

  Widget _map() {
    return SingleChildScrollView(
      child: Container(
        // height: 200,
        // width: 200,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: const Text(
                      '取消',
                      style: TextStyle(color: Colors.amberAccent),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    width: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.grey.shade200,
                    ),
                    child: TextField(
                      controller: positionController,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        icon: Icon(Icons.search),
                        border: InputBorder.none,
                        hintText: "搜索",
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // serchPosition(positionController.text);
                      Get.back(result: {
                        'list': _poiList[0].toMap(),
                        'longitude': _location.longitude,
                        'latitude': _location.latitude
                      });
                    },
                    child: const Text(
                      '确定',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 650,
              child: BMFMapWidget(
                onBMFMapCreated: (controller) {
                  //自定义onBMFMapCreated方法，用于获取controller
                  onBMFMapCreated(controller);
                },
                mapOptions: BMFMapOptions(
                  center: BMFCoordinate(32.1249347, 118.9474712),
                  zoomLevel: 12,
                  mapPadding:
                      BMFEdgeInsets(left: 30, top: 0, right: 30, bottom: 0),
                ),
              ),
            ),
            //列表渲染略过
          ],
        ),
      ),
    );
  }

  void onBMFMapCreated(BMFMapController controller) {
    _controller = controller;
    _controller.showUserLocation(true);
  }

  //  申请权限
  Future<bool> requestPermission() async {
    // 申请权限
    final status = await Permission.location.request();
    if (status.isGranted) {
      print("定位权限申请通过");
      return true;
    } else {
      print("定位权限申请不通过");
      return false;
    }
  }

  /// 停止定位
  void _stopLocation() {
    if (null != _locationPlugin) {
      _locationPlugin.stopLocation();
    }
  }

  //  开始定位
  void _startLocation() {
    if (null != _locationPlugin) {
      //申请定位权限
      requestPermission().then((value) => {
            if (value)
              {_setLocOption(), _locationPlugin.startLocation()}
            else
              {
                EasyLoading.showToast("需要定位权限",
                    toastPosition: EasyLoadingToastPosition.bottom)
              }
          });
    }
  }

  //  设置定位参数
  void _setLocOption() {
    if (Platform.isIOS) {
      BMFMapSDK.setApiKeyAndCoordType(
          'OegaCZ8Nom0Az78EXbql6x7fa4FDDx7u', BMF_COORD_TYPE.BD09LL);
    } else if (Platform.isAndroid) {
      androidOption.setCoorType("bd09ll"); // 设置返回的位置坐标系类型
      androidOption.setIsNeedAltitude(true); // 设置是否需要返回海拔高度信息
      androidOption.setIsNeedAddress(true); // 设置是否需要返回地址信息
      androidOption.setIsNeedLocationPoiList(true); // 设置是否需要返回周边poi信息
      androidOption.setIsNeedNewVersionRgc(true); // 设置是否需要返回最新版本rgc信息
      androidOption.setIsNeedLocationDescribe(true); // 设置是否需要返回位置描述
      androidOption.setOpenGps(true); // 设置是否需要使用gps
      androidOption.setLocationMode(BMFLocationMode.hightAccuracy); // 设置定位模式
      androidOption.setScanspan(1000); // 设置发起定位请求时间间隔
    }
    Map androidMap = androidOption.getMap();
    Map iosdMap = iosOption.getMap();
    _locationPlugin.prepareLoc(androidMap, iosdMap); //ios和安卓定位设置
  }

  void updatePosition() {
    BMFCoordinate coordinate = BMFCoordinate(
        _location.latitude ?? 39.917215, _location.longitude ?? 116.380341);

    BMFMapOptions options = BMFMapOptions(
        center: coordinate,
        zoomLevel: 17,
        mapPadding: BMFEdgeInsets(left: 30, top: 0, right: 30, bottom: 0));

    BMFLocation location = BMFLocation(
        coordinate: coordinate,
        altitude: 0,
        horizontalAccuracy: 5,
        verticalAccuracy: -1.0,
        speed: -1.0,
        course: -1.0);

    BMFUserLocation userLocation = BMFUserLocation(
      location: location,
    );

    setState(() {
      _poiList = _location.pois!;
    });
    _controller.updateLocationData(userLocation);
    _controller.updateMapOptions(options);
  }
}
