import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import './classes.dart';

class MapPage extends StatelessWidget {
  final Maptale tale;
  final Function callPlayNode;

  MapPage(this.tale, this.callPlayNode);

  //https://rbrundritt.wordpress.com/2009/07/21/determining-best-map-view-for-an-array-of-locations/
  MapOptions get mapCenter {
    double zoomLevel = 0.0;
    double maxLat = -85.0;
    double minLat = 85.0;
    double maxLon = -180;
    double minLon = 180;

    for (var node in tale.nodes) {
      if (node.location.latitude > maxLat) {
        maxLat = node.location.latitude;
      }
      if (node.location.latitude < minLat) {
        minLat = node.location.latitude;
      }
      if (node.location.longitude > maxLon) {
        maxLon = node.location.longitude;
      }
      if (node.location.longitude < minLon) {
        minLon = node.location.longitude;
      }
    }

    double centerLat = (maxLat + minLat) / 2;
    double centerLon = (maxLon + minLon) / 2;

    double zoomLat = 0, zoomLon = 0;

    int mapWidth = 720, mapHeight = 1280;

    zoomLon = log(360.0/256.0 * (mapWidth - 30)/(maxLon - minLon))/log(2);
    zoomLat = log(180.0/256.0 * (mapHeight - 30)/(maxLat - minLat))/log(2);

    zoomLevel = (zoomLon < zoomLat) ? zoomLon : zoomLat;

    return MapOptions(
      center: LatLng(centerLat, centerLon),
      zoom: zoomLevel,
    );
  }

  List<Marker> get markers {
    return tale.nodes.map((node) {
      if (node.visible || node.visited) {
        return Marker(
          width: 48.0,
          height: 48.0,
          point: LatLng(node.location.latitude, node.location.longitude),
          builder: (ctx) => Container(
            child:IconButton(
              icon: Icon(Icons.location_on),
              iconSize: 48.0,
              color: Colors.red,
              onPressed: () {
                callPlayNode(node.id);
              },
            ),
            //Image(image: AssetImage('assets/img/node.png')),
          )
        );
      } else {
        return null;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: FlutterMap(
          options: mapCenter,
          layers: [
            TileLayerOptions(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c']
            ),
            MarkerLayerOptions(
              markers: markers
            )
          ],
        ),
      ),
    );
  }
}
