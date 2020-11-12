import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter/services.dart';
import 'package:wallpaperplugin/wallpaperplugin.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class WallpaperPage extends StatefulWidget {
  @override
  _WallpaperPageState createState() => _WallpaperPageState();
}

class _WallpaperPageState extends State<WallpaperPage> {

  var client_id = 'G5x9vn38tzXtiHcpX_gaOrOtOGCUPGRp-K1H9pHNQBI';
  var url = 'https://api.unsplash.com/search/photos';

  List data;
  String _localpath;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchImagesData();
  }

  Future<String> fetchImagesData() async{
    var fetchData = await http.get('$url?per_page=30&client_id=$client_id&query=nature');

    var jsonData = json.decode(fetchData.body);

    setState(() {
      data = jsonData['results'];
    });

    return 'Success';
  }

  static Future<bool> _checkAndGetPermission() async {
    final PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
    if (permission != PermissionStatus.granted) {
      final Map<PermissionGroup, PermissionStatus> permissions =
      await PermissionHandler().requestPermissions(<PermissionGroup>[PermissionGroup.storage]);
      if (permissions[PermissionGroup.storage] != PermissionStatus.granted) {
        return null;
      }
    }
    return true;
  }

  _onTapImage(context, data){
    return AlertDialog(
      title: Text('Jadikan Wallpaper ?', style: TextStyle(color: Colors.blue)),
      actions: <Widget>[
        MaterialButton(
          onPressed: () async{
            if(_checkAndGetPermission() != null){
              Dio dio = Dio();

              final Directory appDir = await getExternalStorageDirectory();
              final Directory directory = await Directory(appDir.path+'/wallpapers').create(recursive: true);
              final String dir = directory.path;
              String localpath = '$dir/myimages.jpeg';

              try{
                
                dio.download(data, localpath);
                setState(() {
                  _localpath = localpath;
                });

                Wallpaperplugin.setAutoWallpaper(localFile: _localpath);

              }on PlatformException catch(e){
                print(e);
              }

              Navigator.pop(context);
            }
          },
          child: Text('Ya, Jadikan Wallpaper', style: TextStyle(color: Colors.blue),)
        ),
        MaterialButton(
          onPressed: (){
            Navigator.pop(context);
          },
          child: Text('Batal', style: TextStyle(color: Colors.blue)),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Aplikasi Wallpaper'),
      ),
      body: Builder(
        builder: (context) => Swiper(
          itemBuilder: (BuildContext context, int index){
            return Stack(
              children: <Widget>[
                InkWell(
                  onTap: (){
                    showDialog(
                        context: context,
                        builder: (context) => _onTapImage(context, data[index]['urls']['small']));
                  },
                  child: Center(
                    child: Image.network(
                      data[index]['urls']['small'],
                      fit: BoxFit.cover,
                      height: 450,
                    ),
                  ),
                )
              ],
            );
          },
          itemCount: 10,
          viewportFraction: 0.8,
          scale: 0.8
        ),
      )
    );
  }
}
