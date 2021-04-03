import 'dart:io';
import 'package:flutter/material.dart';
import './classes.dart';
import './play.dart';

class CoverDetailPage extends StatelessWidget {
  final Maptale tale;

  CoverDetailPage(this.tale);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tale.title),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Image.file(File("${tale.dir}/${tale.coverImage}")),
          ),
          Text(tale.title),
          Text(tale.subTitle),
          Text('by'),
          Text(tale.author),
          Container(
            alignment: Alignment.center,
            color: Colors.red,
            margin: EdgeInsets.all(10),
            child: SizedBox(
              width: double.infinity,
              child: IconButton(
                icon: Icon(Icons.play_arrow),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (ctx) => PlayPage(tale)));
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
