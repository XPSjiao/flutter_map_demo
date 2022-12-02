# Flutter集成百度地图

## 一、申请百度开放平台AK

[百度开放平台]: https://lbsyun.baidu.com/	"百度开放平台"

### 1、进入开放平台的控制台

![image-20221130131322249](https://soft2176-use.oss-cn-hangzhou.aliyuncs.com/md-pic/image-20221130131322249.png)

使用个人信息获得开发者认证

### 2、创建应用获取AK

![image-20221130131445856](https://soft2176-use.oss-cn-hangzhou.aliyuncs.com/md-pic/image-20221130131445856.png)

![image-20221130131501562](https://soft2176-use.oss-cn-hangzhou.aliyuncs.com/md-pic/image-20221130131501562.png)

根据自己的需求来写相关应用名称等信息

#### 获取SHA1

windows和mac的指令一样，这里以windows系统举例获取SHA1

win + r cmd 打开cmd控制台，mac就是进入进入终端

输入 命令进入”.android”文件夹下

```bash
cd .android
```

![image-20221130131909169](https://soft2176-use.oss-cn-hangzhou.aliyuncs.com/md-pic/image-20221130131909169.png)

继续在控制台输入命令:

调试版本使用指令：

```bash
keytool -list -v -keystore debug.keystore
```

debug模式的默认的口令为：

```bash
android
```

![image-20221130132217200](https://soft2176-use.oss-cn-hangzhou.aliyuncs.com/md-pic/image-20221130132217200.png)

发布版本请使用指令:

```bash
keytool -list -v -keystore apk.keystore
```

密码为自行设置的

![image-20221130132411354](https://soft2176-use.oss-cn-hangzhou.aliyuncs.com/md-pic/image-20221130132411354.png)

如果查看密钥的指令报错：

```bash
java.lang.Exception：密钥库文件不存在
```

使用以下命令生成密钥：

调试版：

```bash
 keytool -genkey -v -keystore debug.keystore -alias androiddebugkey -keyalg RSA -validity 10000
```

发布版:

```bash
 keytool -genkey -v -keystore apk.keystore -alias androiddebugkey -keyalg RSA -validity 10000
```

然后根据里面的提示输入自己的相关信息，最后确认就创建好了。

#### 获取PackageName

包名是Android应用程序本身在AndroidManifest.xml 中定义的名称

![image-20221130133047445](https://soft2176-use.oss-cn-hangzhou.aliyuncs.com/md-pic/image-20221130133047445.png)

将相关信息填写完成之后将生成自己的应用，然后把自己的AK复制出来

![image-20221130133246944](https://soft2176-use.oss-cn-hangzhou.aliyuncs.com/md-pic/image-20221130133246944.png)

## 二、demo实现

### 1、添加依赖

```yaml
  # 百度地图
  flutter_bmflocation: ^3.3.0
  flutter_baidu_mapapi_map: ^3.0.0+2
  flutter_baidu_mapapi_search: ^3.0.0
  # 权限请求
  permission_handler: ^10.2.0
```

### 2、android目录下配置

```xml
<meta-data
           android:name="com.baidu.lbsapi.API_KEY"
           android:value="你的百度AK" />
```

![image-20221130133620709](https://soft2176-use.oss-cn-hangzhou.aliyuncs.com/md-pic/image-20221130133620709.png)

kotlin/java目录下添加myapplication.java类

注意修改包名

报错不用管可以跑的

```java
package com.example.flutter_map_demo;

import com.baidu.mapapi.base.BmfMapApplication;
import io.flutter.app.FlutterApplication;

public class MyApplication extends BmfMapApplication  {

    @Override
    public void onCreate() {
        super.onCreate();
    }
}
```

![image-20221130133809554](https://soft2176-use.oss-cn-hangzhou.aliyuncs.com/md-pic/image-20221130133809554.png)

xml中修改android:name

它是用来app启动时来关联一个application的，默认关联的是android.app.Application

![image-20221130133849037](https://soft2176-use.oss-cn-hangzhou.aliyuncs.com/md-pic/image-20221130133849037.png)

### 3、ios配置流程

iOS端的UiKitView目前还只是preview状态, 默认是不支持的, 需要手动打开开关, 需要在iOS工程的info.plist添加如下配置：

```xml
<key>io.flutter.embedded_views_preview</key> 
<string>YES</string><key>io.flutter.embedded_views_preview</key> 
<string>YES</string>
```

地图sdk鉴权需要配置BundleDisplayName, 需要在iOS工程Info.plist中添加如下配置：

```xml
<key>CFBundleDisplayName</key> 
<string>app名称</string>
```

![image-20221130134052010](https://soft2176-use.oss-cn-hangzhou.aliyuncs.com/md-pic/image-20221130134052010.png)

### 4、Flutter中使用地图widget

百度地图的widget为BMFMapWidget

```dart
BMFMapWidget(
  onBMFMapCreated: (controller) {
            //自定义onBMFMapCreated方法，用于获取controller
            onBMFMapCreated(controller);
          },
  mapOptions: BMFMapOptions(
            center: BMFCoordinate(39.917215, 116.380341),
            zoomLevel: 12,
            mapPadding:
            BMFEdgeInsets(left: 30, top: 0, right: 30, bottom: 0)),
)
```

定义controller

```dart
  late BMFMapController _controller;
 
 
 void onBMFMapCreated(BMFMapController controller) {
    _controller = controller;
    _controller.showUserLocation(true);
  }
```

**使用定位获取坐标，居中显示**

声明所需的几个变量

```dart
  late LocationFlutterPlugin _locationPlugin;
 
  BaiduLocationIOSOption iosOption =
      BaiduLocationIOSOption(coordType: BMFLocationCoordType.gcj02);
 
  BaiduLocationAndroidOption androidOption =
      BaiduLocationAndroidOption(coordType: BMFLocationCoordType.gcj02);
 
  late BMFMapController _controller;
 
  late BaiduLocation _location;
```

在initState中初始化。
**注意**
_locationPlugin.setAgreePrivacy(true);
**这句话在百度教程没有 是否同意隐私协议的东西 不加上不会加载地图** 

```dart
  @override
  void initState() {
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
```

Android权限申请

```dart
//  申请权限
  Future<bool> requestPermission() async {
    // 申请权限
    final status = await Permission.location.request();
    //获取存储权限，可能涉及到地图的shareprefences读写问题，建议加上并进行判断
    //await Permission.storage.status;
 
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
                    toastPosition:EasyLoadingToastPosition.bottom)
              }
          });
    }
  }
 
//  设置定位参数
  void _setLocOption() {
    androidOption.setCoorType("bd09ll"); // 设置返回的位置坐标系类型
    androidOption.setIsNeedAltitude(true); // 设置是否需要返回海拔高度信息
    androidOption.setIsNeedAddress(true); // 设置是否需要返回地址信息
    androidOption.setIsNeedLocationPoiList(true); // 设置是否需要返回周边poi信息
    androidOption.setIsNeedNewVersionRgc(true); // 设置是否需要返回最新版本rgc信息
    androidOption.setIsNeedLocationDescribe(true); // 设置是否需要返回位置描述
    androidOption.setOpenGps(true); // 设置是否需要使用gps
    androidOption.setLocationMode(BMFLocationMode.hightAccuracy); // 设置定位模式
    androidOption.setScanspan(1000); // 设置发起定位请求时间间隔
    Map androidMap = androidOption.getMap();
    Map iosdMap = iosOption.getMap();
    _locationPlugin.prepareLoc(androidMap, iosdMap); //ios和安卓定位设置
  }
 
```

**ios支持**

修改_setLocOption方法 需要申请下ios的sdk

```Dart
void _setLocOption() {
    if (Platform.isIOS) {
      BMFMapSDK.setApiKeyAndCoordType(
          'ios sdk', BMF_COORD_TYPE.BD09LL);
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
```

依赖无法自动识别 需要以下这种方式导入

```dart
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart'
    show BMFMapSDK, BMF_COORD_TYPE;
```

**附近地点列表**

插件callback的result中有pois属性 存储了附近地点 直接使用即可

![image-20221130134407288](https://soft2176-use.oss-cn-hangzhou.aliyuncs.com/md-pic/image-20221130134407288.png)

在updatePosition中更新下poiList

```dart
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
```

**getx回退页面传值**

getx可以通过back()方法携带result传值给上一个页面 把选择的地址传递回去

```dart
Get.back(result: {
                      'list': _poiList[0].toMap(),
                      'longitude': _location.longitude,
                      'latitude': _location.latitude
                    });
```

**完整代码**

```dart
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart'
    show BMFMapSDK, BMF_COORD_TYPE;
import 'package:flutter_baidu_mapapi_base/src/map/bmf_models.dart';
import 'package:flutter_baidu_mapapi_map/flutter_baidu_mapapi_map.dart';
import 'package:flutter_baidu_mapapi_search/flutter_baidu_mapapi_search.dart';
import 'package:flutter_bmflocation/flutter_bmflocation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../data/base_style.dart';
import '../../../data/school_theme_data.dart';

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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          "选取地点",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: SchoolConfig.primaryColor,
      ),
      body: _map(),
    );
  }

  Widget _map() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.r),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Text(
                    '取消',
                    style: BaseStyle.schoolContentStyle,
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10.r),
                  padding: EdgeInsets.symmetric(horizontal: 10.r),
                  width: 300.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.r),
                    color: Colors.grey.shade200,
                  ),
                  child: TextField(
                    controller: positionController,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      icon: Icon(Icons.search),
                      border: InputBorder.none,
                      hintText: "搜索",
                      hintStyle: const TextStyle(
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
                  child: Text(
                    '确定',
                    style: BaseStyle.schoolContentStyle,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 300.h,
            child: BMFMapWidget(
              onBMFMapCreated: (controller) {
                //自定义onBMFMapCreated方法，用于获取controller
                onBMFMapCreated(controller);
              },
              mapOptions: BMFMapOptions(
                center: BMFCoordinate(39.917215, 116.380341),
                zoomLevel: 12,
                mapPadding:
                    BMFEdgeInsets(left: 30, top: 0, right: 30, bottom: 0),
              ),
            ),
          ),
          //列表渲染略过
        ],
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
```

所有依赖


```yaml
dependencies:
  flutter:
    sdk: flutter
#  amap_map_fluttify: ^2.0.0

  # 百度地图
  flutter_bmflocation: ^3.3.0
  flutter_baidu_mapapi_map: ^3.0.0+2
  flutter_baidu_mapapi_search: ^3.0.0
  # 权限请求
  permission_handler: ^10.2.0
#  get
  get: ^4.6.5
  flutter_easyloading: ^3.0.5
  flutter_screenutil: ^5.6.0
  # The following adds the Cupertino Icons font to your application.
  # Use with the CupertinoIcons class for iOS style icons.
  cupertino_icons: ^1.0.2

```

实现效果

![image-20221130134729002](https://soft2176-use.oss-cn-hangzhou.aliyuncs.com/md-pic/image-20221130134729002.png)
