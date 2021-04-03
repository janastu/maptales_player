import 'package:flutter/material.dart';
import 'package:maptales_player/classes.dart';
import 'dart:io';
import './cover_detail.dart';

class Cover extends StatelessWidget {
  final Maptale tale;

  Cover(this.tale);

  @override
  Widget build(BuildContext context) {
    //print("in Cover build; ${tale.dir}/${tale.coverImage}");
    return GestureDetector(
      onTap: () {
        //print("Tapped book");
        Navigator.push(
            context,
            MaterialPageRoute(builder: (ctx) => CoverDetailPage(tale)));

      } ,
      child: Column(
        children: <Widget>[
          /*Container(
            width: 120,
            height: 170,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: FileImage(File('${tale.dir}/${tale.coverImage}')),
                fit: BoxFit.cover,
              )
            ),
          ),
           */
          Expanded(
            child: Image.file(File("${tale.dir}/${tale.coverImage}")),
          ),
          Text(tale.title),
          Text(tale.subTitle),
        ],
      ),
    );
  }
}