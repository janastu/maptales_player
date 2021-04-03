import 'package:flutter/material.dart';

class MaptaleLocation {
  final double latitude;
  final double longitude;
  final double radius; //trigger radius in meters
  MaptaleLocation({ this.latitude, this.longitude, this.radius });

  factory MaptaleLocation.fromJSON(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    final coords = json['geometry']['coordinates'];
    return MaptaleLocation(
      longitude: coords[0],
      latitude: coords[1],
      radius: json['properties']['radius'],
    );
  }
}

class Maptale {
  Maptale({ this.title, this.subTitle, this.author,
    this.pubDate, this.coverImage, this.version,
    this.startLocation });

  String dir;
  final String title;
  final String subTitle;
  final String author;
  final String version;
  final DateTime pubDate;
  final String coverImage;
  final MaptaleLocation startLocation;

  final List<MaptaleNode> nodes = List<MaptaleNode>();

  factory Maptale.fromJSON(Map<String, dynamic> json) {
    return Maptale(
      title: json['title'],
      subTitle: json['subTitle'],
      author: json['author'],
      version: json['version'],
      pubDate: DateTime.parse(json['pubDate']),
      coverImage: json['coverImage'],
      startLocation: MaptaleLocation.fromJSON(json['startLocation']),
    );
  }

  void readNodesFromJSON(List<Map<String, dynamic>> json) {
    for (var node in json) {
      nodes.add(MaptaleNode.fromJSON(node));
    }
  }

  void addNode(MaptaleNode node) {
    nodes.add(node);
  }
}

class MaptaleNode {
  MaptaleNode({ this.id, this.content, this.script, this.location });

  final int id;
  final String content;
  final String script;
  final MaptaleLocation location;
  bool visited = false;
  bool visible = true;

  factory MaptaleNode.fromJSON(Map<String, dynamic> json) {
    return MaptaleNode(
      id: json['id'],
      content: json['content'] is List<dynamic> ? json['content'].join('\n') : json['content'],
      script: json['script'],
      location: MaptaleLocation.fromJSON(json['location']),
    );
  }

}