import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:maptales_player/classes.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:location/location.dart';
import './map.dart';

class PlayPage extends StatelessWidget {
  final Maptale tale;
  final Completer<WebViewController> _completer = Completer<WebViewController>();
  WebViewController _controller;
  BuildContext _context;

  PlayPage(this.tale);

  void playNode(int id) async {
    Navigator.of(_context).pop(true);
    await _controller.loadUrl('file://${tale.dir}/index.html#$id');
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Scaffold(
      appBar: AppBar(
        title: Text("Playing: ${tale.title}"),
      ),
      body: WebView(
        initialUrl: 'file://${tale.dir}/index.html',
        javascriptMode: JavascriptMode.unrestricted,
        javascriptChannels: Set.from([
          JavascriptChannel(
            name: 'flutterNodeActivate',
            onMessageReceived: (JavascriptMessage message) {
              print("Activate node: ${message.message}");
            }
          ),
          JavascriptChannel(
            name:'flutterNodeDeactivate',
            onMessageReceived: (JavascriptMessage message) {
              print("Deactivate node: ${message.message}");
            }
          )
        ]),
        onWebViewCreated: (WebViewController webViewController) {
          _completer.complete(webViewController);
          _controller = webViewController;
          //String content = File(tale.dir + '/index.html').readAsStringSync();
          //_controller.loadUrl(Uri.dataFromString(content, mimeType: 'text/html', encoding: Encoding.getByName('utf-8')).toString());
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Map',
        child: Icon(Icons.navigation),
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (ctx) => MapPage(tale, playNode)));
        },
      ),
    );
  }
}
