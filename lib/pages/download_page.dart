// @dart=2.9
import 'dart:isolate';
import 'dart:ui';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';

class DownLoadPage extends StatefulWidget {
  const DownLoadPage({
    Key key,
    this.title,
    this.url,
    this.version,
    this.appName,
  }) : super(key: key);
  final String appName;
  final String title;
  final String url;
  final String version;

  @override
  _DownLoadPageState createState() => _DownLoadPageState();
}

class _DownLoadPageState extends State<DownLoadPage> {
  // static String _savePath = "/storage/emulated/0/Download";
  static String _localPath = "";
  String mytaskId = "";
  //static String _fileName= Random().nextInt(999999).toString()+"thai2dlive.apk";
  List _documents = [];

  static List<_TaskInfo> _tasks;
  List<_ItemHolder> _items;
  bool _isLoading;
  bool _permissionReady;
  List<String> supportApk = [];
  String apkLink = "";

  final ReceivePort _port = ReceivePort();
  String fileName = "";

  String version = "";

  @override
  void initState() {
    super.initState();
    apkLink = widget.url;
    version = widget.version;
    fileName = widget.appName;
    // Random().nextInt(999999).toString() + "thai2dlive.apk";

    initPlatformState();
    _bindBackgroundIsolate();

    FlutterDownloader.registerCallback(downloadCallback);

    _isLoading = true;
    _permissionReady = false;
    _items = [];
    _tasks = [];

    _prepare();
    _checkPermission();

    // downloadFile();
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
  }

  Future<void> initPlatformState() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    try {
      if (!kIsWeb) {
        if (Platform.isAndroid) {
          var build = await deviceInfo.androidInfo;
          supportApk = build.supportedAbis;

          apkLink = widget.url;
          // if (supportApk.isNotEmpty) {
          //   apkLink = widget.url;
          //   // armeabi-v7a,arm64-v8a,x86,x86_64
          //   if (supportApk.contains("armeabi-v7a")) {
          //     apkLink = widget.apkV7AUrl;
          //   } else if (supportApk.contains("arm64-v8a")) {
          //     apkLink = widget.apkV8AUrl;
          //   } else if (supportApk.contains("x86_64")) {
          //     apkLink = widget.apkX86_64Url;
          //   }

          //   // apkLink = widget.url.replaceAll(
          //   //     "thai2dlive.apk", "thai2dlive-" + supportApk[0] + ".apk");
          // } else {
          //   apkLink = widget.url;
          // }

          _documents = [
            {'name': fileName, 'link': apkLink}
          ];
        }
      }
      // ignore: empty_catches, non_constant_identifier_names
    } catch (PlatformException) {}

    if (!mounted) return;
  }

  Future<void> _bindBackgroundIsolate() async {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) async {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];

      if (_tasks != null && _tasks.isNotEmpty) {
        if (data[1] == const DownloadTaskStatus(3)) {
          // String path = _savePath + "/" + fileName;
          // var obj = {
          //   "deviceId":deviceId,
          //   "version":widget.version,
          //   "downloadLink":path,
          //   "downloaderId":data[0]
          // };

          Navigator.of(context).pop();
          _installApk(data[0]);
          // Future.delayed(const Duration(seconds: 2), () {
          //
          // });
        }
        if (data[1] == const DownloadTaskStatus(4)) {
          _retryDownload(data);
        }
        if (data[1] == const DownloadTaskStatus(0)) {
          _requestDownload(data);
        }
        final task = _tasks.firstWhere((task) => task.taskId == id);
        setState(() {
          task.status = status;
          task.progress = progress;
        });
      }
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    /*if (debug) {
      print(
          'Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
    }*/

    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }

  @override
  Widget build(BuildContext context) {
    // return new Scaffold(
    //   appBar: new AppBar(
    //     title: new Text("Test Download"),
    //   ),
    //   body: Builder(
    //       builder: (context) => _isLoading
    //           ? new Center(
    //         child: new CircularProgressIndicator(),
    //       )
    //           : _permissionReady
    //           ? _buildDownloadList()
    //           : _buildNoPermissionWarning()),
    // );

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        content: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      child: (_items.isNotEmpty)
                          ? _buildDownloadList()
                          : const Text("Loading...")
                      // Builder(
                      //       builder: (context) => _isLoading
                      //           ? new Center(
                      //         child: new CircularProgressIndicator(),
                      //       )
                      //           : _permissionReady
                      //           ? _buildDownloadList()
                      //           : _buildNoPermissionWarning()),
                      )
                  //LinearProgressIndicator(value: _pro),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _onBackPressed() async {
    return false;
  }

  Widget _buildDownloadList() {
    return SizedBox(
      height: 100,
      child: _items.isNotEmpty
          ? Wrap(
              //padding: const EdgeInsets.symmetric(vertical: 16.0),
              children: _items
                  .map((item) => item.task == null
                      ? const Text("")
                      : DownloadItem(
                          title: widget.title,
                          data: item,
                          onActionClick: (task) {
                            if (task.status == DownloadTaskStatus.failed) {
                              _retryDownload(task);
                            }
                          },
                        ))
                  .toList(),
            )
          : const Text("Loading..."),
    );
  }

  // Widget _buildListSection(String title) => Container(
  //       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
  //       child: Text(
  //         title,
  //         style: const TextStyle(
  //             fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 18.0),
  //       ),
  //     );

  // Widget _buildNoPermissionWarning() => Container(
  //       child: Center(
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.center,
  //           children: [
  //             Padding(
  //               padding: const EdgeInsets.symmetric(horizontal: 24.0),
  //               child: Text(
  //                 'Please grant accessing storage permission to continue -_-',
  //                 textAlign: TextAlign.center,
  //                 style: TextStyle(color: Colors.blueGrey, fontSize: 18.0),
  //               ),
  //             ),
  //             SizedBox(
  //               height: 32.0,
  //             ),
  //             FlatButton(
  //                 onPressed: () {
  //                   _retryRequestPermission();
  //                 },
  //                 child: Text(
  //                   'Retry',
  //                   style: TextStyle(
  //                       color: Colors.blue,
  //                       fontWeight: FontWeight.bold,
  //                       fontSize: 20.0),
  //                 ))
  //           ],
  //         ),
  //       ),
  //     );

  // Future<void> _retryRequestPermission() async {
  //   final hasGranted = await _checkPermission();

  //   if (hasGranted) {
  //     await _prepareSaveDir();
  //   }

  //   setState(() {
  //     _permissionReady = hasGranted;
  //   });
  // }

  void _requestDownload(_TaskInfo task) async {
    task.taskId = await FlutterDownloader.enqueue(
        url: task.link,
        fileName: task.name,
        headers: {"auth": "test_for_sql_encoding"},
        savedDir: _localPath,
        showNotification: true,
        openFileFromNotification: true);
  }

  void _retryDownload(_TaskInfo task) async {
    String newTaskId = await FlutterDownloader.retry(taskId: task.taskId);
    task.taskId = newTaskId;
  }

  static Future<void> _installApk(String taskId) async {
    final task = _tasks?.firstWhere((task) => task.taskId == taskId);
    // String path = _savePath + "/" + task.name;
    String path = _localPath + "/" + task.name;
    // path: /storage/emulated/0/Download/515310thai2dlive.apk
    // path1: /storage/emulated/0/Android/data/com.example.thai2dlive/files/515310thai2dlive.apk
    // OpenResult result1 = await OpenFile.open(path1);
    // print(result1.type);
    //  print("jake:finished already"+/.type.toString());
    await OpenFile.open(path);

    //print("result = "+ result.type.toString()+" / message = "+result.message);
    // /await AppInstaller.installApk(path);
  }

  Future<bool> _checkPermission() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    if (Platform.isAndroid && androidInfo.version.sdkInt <= 28) {
      final status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.storage.request();
        if (result == PermissionStatus.granted) {
          await _prepareSaveDir();
          return true;
        }
      } else {
        await _prepareSaveDir();
        return true;
      }
    } else {
      await _prepareSaveDir();
      return true;
    }
    return false;
  }

  Future<void> _prepare() async {
    final tasks = await FlutterDownloader.loadTasks();

    int count = 0;
    _tasks = [];
    _items = [];

    _tasks.addAll(_documents.map((document) =>
        _TaskInfo(name: document['name'], link: document['link'])));

    for (int i = count; i < _tasks.length; i++) {
      _items.add(_ItemHolder(name: _tasks[i].name, task: _tasks[i]));
      count++;
    }

    tasks.forEach((task) {
      for (_TaskInfo info in _tasks) {
        if (info.link == task.url) {
          info.taskId = task.taskId;
          info.status = task.status;
          info.progress = task.progress;
        }
      }
    });

    _permissionReady = await _checkPermission();

    if (_permissionReady) {
      await _prepareSaveDir();
      _requestDownload(_tasks[0]);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _prepareSaveDir() async {
    _localPath = (await _findLocalPath());
    final savedDir = Directory(_localPath);

    // "/storage/emulated/0/Android/data/com.example.thai2dlive/files"
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
  }

  Future<String> _findLocalPath() async {
    var externalStorageDirPath;
    if (Platform.isAndroid) {
      try {
        final directory = await getExternalStorageDirectory();
        externalStorageDirPath = directory?.path;
        //externalStorageDirPath = await AndroidPathProvider.downloadsPath;
      } catch (e) {
        final directory = await getExternalStorageDirectory();
        externalStorageDirPath = directory?.path;
      }
    }
    // var test = externalStorageDirPath.toString();
    return externalStorageDirPath;
  }
}

class DownloadItem extends StatelessWidget {
  final _ItemHolder data;
  final Function(_TaskInfo) onActionClick;
  final String title;

  // ignore: use_key_in_widget_constructors
  const DownloadItem({this.title, this.data, this.onActionClick});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16.0, right: 8.0),
      child: Stack(
        children: <Widget>[
          // Image.asset(
          //   "assets/login.jpg",
          //   height: 100,
          //   fit: BoxFit.cover,
          // ),
          const SizedBox(
            width: double.infinity,
            height: 80.0,
            child: Text(
              "Please wait.Your version is updating.", //title!,
              //maxLines: 1,
              //softWrap: true,
              //overflow: TextOverflow.ellipsis,
            ),
            // Row(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: <Widget>[
            //     Expanded(
            //       child: Text(
            //         title!,
            //         maxLines: 1,
            //         softWrap: true,
            //         overflow: TextOverflow.ellipsis,
            //       ),
            //     ),
            //     Padding(
            //       padding: const EdgeInsets.only(left: 8.0),
            //       child: _buildActionForTask(data!.task!),
            //     ),
            //   ],
            // ),
          ),
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: data.task.status == DownloadTaskStatus.running
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: LinearProgressIndicator(
                      value: data.task.progress / 100,
                      minHeight: 6,
                      backgroundColor: Colors.grey,
                    ),
                  )
                : const Text("Loading..."),
          )
        ].toList(),
      ),
    );
  }

  // Widget _buildActionForTask(_TaskInfo task) {
  //   if (task.status == DownloadTaskStatus.failed) {
  //     return Row(
  //       mainAxisSize: MainAxisSize.min,
  //       mainAxisAlignment: MainAxisAlignment.end,
  //       children: [
  //         Text('Failed', style: TextStyle(color: Colors.red)),
  //         RawMaterialButton(
  //           onPressed: () {
  //             onActionClick(task);
  //           },
  //           child: Icon(
  //             Icons.refresh,
  //             color: Colors.green,
  //           ),
  //           shape: CircleBorder(),
  //           constraints: BoxConstraints(minHeight: 32.0, minWidth: 32.0),
  //         )
  //       ],
  //     );
  //   } else {
  //     return null;
  //   }
  // }

}

class _TaskInfo {
  final String name;
  final String link;

  String taskId;
  int progress = 0;
  DownloadTaskStatus status = DownloadTaskStatus.running;

  _TaskInfo({this.name, this.link});
}

class _ItemHolder {
  final String name;
  final _TaskInfo task;

  _ItemHolder({this.name, this.task});
}
