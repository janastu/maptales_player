//import 'dart:html';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:maptales_player/classes.dart';
import 'package:maptales_player/cover.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
//import 'package:simple_permissions/simple_permissions.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:glob/glob.dart';

void main() {
  runApp(MaptalesApp());
}

class MaptalesApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maptales - Player',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.red,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ShelfWidget(),
    );
  }
}



class ShelfWidget extends StatefulWidget {
  @override
  _ShelfWidgetState createState() => _ShelfWidgetState();
}

class _ShelfWidgetState extends State<ShelfWidget> {
  final _tale = Maptale(
      title: "First geo-tale",
      subTitle: "Sub title",
      author: "Arun Kumar",
      pubDate: DateTime.parse("2020-04-20T12:00:00+0530"),
      coverImage: null);
  String _tmpDir;
  String _appDir;
  final searchController = TextEditingController();
  final List<Maptale> tales = [];

  @override
  void initState() {
    super.initState();
    _initDir();
    _readMptls();
    print('tmp: $_tmpDir, app: $_appDir');
  }

  _initDir() async {
    if (null == _tmpDir || null == _appDir) {
      //_tmpDir = (await getTemporaryDirectory()).path;
      //_appDir = (await getApplicationDocumentsDirectory()).path;
      _tmpDir = '/storage/emulated/0/Documents';
      _appDir = '/storage/emulated/0/Documents';
      //print('tmp: $_tmpDir, app: $_appDir');
    }
  }

  String _getFilename(String path) => path.split("/").last.split(".")[0];

  _readMptls() async {
    //PermissionStatus permissionResult = await SimplePermissions.requestPermission(Permission.ReadExternalStorage);
    //PermissionStatus permissionWrite = await SimplePermissions.requestPermission(Permission.WriteExternalStorage);

    //if (permissionResult == PermissionStatus.authorized && permissionWrite == PermissionStatus.authorized) {
    if (await Permission.storage.request().isGranted) {
      print("Thanks for giving permission!");
    } else {
      print("Did not get permission to read Documents folder");
    }

    for (var mptlFile in Glob("$_appDir/*.mptl").listSync()) {
      //print(mptlFile.path);
      final dirName = _getFilename(mptlFile.path);
      final bytes = File(mptlFile.path).readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);
      for (final file in archive) {
        final filename = file.name;
        if (file.isFile) {
          final data = file.content as List<int>;
          //print("filename: $filename");
          if (filename == 'cover.json') {
            //var jsn = json.decode(utf8.decode(file.content));
            //print("Json:");
            //print(jsn);
            var tale = Maptale.fromJSON(json.decode(utf8.decode(file.content)));
            tale.dir = '$_tmpDir/$dirName';
            setState(() {
              tales.add(tale);
            });
            //print("coverImage: " + tale.coverImage);
            //print("title: ${tale.title}");
            //print(tales.length);
          } else if (filename == 'nodes.json') {

          }
          File('$_tmpDir/$dirName/' + filename)
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);
        } else {
          Directory('$_tmpDir/$dirName/' + filename)
            ..create(recursive: true);
        }
      }

    }
    for (var tale in tales) {
      /* Reads node.js file which assigns an array to a var called nodes;
       * This code expects the nodes.js to have a certain format
       * The first line is 'var nodes = [' and the last line ends with a '];'
       * So this code replaces the first line with '[' and the last line with ']'
       * so that it can be read by the JSON decoder and decoded.
       */
      var nodesJs = File(tale.dir + '/nodes.js').readAsStringSync();
      LineSplitter ls = LineSplitter();
      List<String> lines = ls.convert(nodesJs);
      lines[0] = '[';
      lines[lines.length - 1] = ']';
      var nodesJson = json.decode(lines.join("\n"));
      tale.readNodesFromJSON(List<Map<String, dynamic>>.from(nodesJson));
      print(tale.nodes);
    }
    //} else {
    //  print("Did not get permission to read external directory");
    //}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My tales'),
      ),
      body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Center(
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      //Text('Search'),
                      Flexible(
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter a search term',
                          ),
                        ),
                      ),
                      RaisedButton(
                        child: Text('Search'),
                        onPressed: () {
                          print(searchController.text);
                        },
                      ),
                    ],
                  ),
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    padding: EdgeInsets.all(20),
                    children: tales.map((tale) {
                      return Cover(tale);
                    }).toList(),
                  ),
                ],
              )
          )
      )
    );
  }
}
