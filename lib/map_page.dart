import 'dart:math';

import 'package:app/mapbox_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

import 'const.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late MapController _mapController;

  List<MapLayer> layers = [
    MapLayer('dark_raster', radarDark, MapLayerType.raster),
    MapLayer('light_raster', radarLight, MapLayerType.raster),
    MapLayer('dark_vector', vectorMapDark, MapLayerType.vector),
    MapLayer('light_vector', vectorMapLight, MapLayerType.vector),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: MapboxWidget(
          onMapLoad: (mapController) async {
            _mapController = mapController;
            await mapController.addImageAssets(
              {
                'stop': 'assets/stop.png',
                'warning': 'assets/warning.png',
              },
            );
          },
          layers: layers,
        ),
      ),
      floatingActionButton: PopupMenuButton(
        padding: EdgeInsets.zero,
        enabled: true,
        itemBuilder: (context) => [
          PopupMenuItem<String?>(
            padding: EdgeInsets.zero,
            value: 'switch_layer',
            onTap: () => _onMenuSelect.call('switch_layer'),
            child: const Center(
              child: Text('switch Layer'),
            ),
          ),
          PopupMenuItem<String?>(
            padding: EdgeInsets.zero,
            value: 'add_marker',
            onTap: () => _onMenuSelect.call('add_marker'),
            child: const Center(
              child: Text('Add marker'),
            ),
          )
        ],
        child: const Icon(
          Icons.menu,
          color: Colors.red,
        ),
      ),
    );
  }

  Future<void> _onMenuSelect(String action) async {
    if (action == 'switch_layer') {
      showDialog(
          context: context,
          useSafeArea: true,
          builder: (context) {
            return Dialog(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: layers
                    .map((e) => TextButton(
                          onPressed: () {
                            _mapController.switchLayer(e.name);
                            Navigator.of(context).pop();
                          },
                          child: Text(e.name),
                        ))
                    .toList(),
              ),
            );
          });
    } else if (action == 'add_marker') {
      List<MapMarker> markers = [];
      for (int i = 2; i < 15; i++) {
        Random r = Random();
        markers.add(
          MapMarker(
            i,
            "stop",
            LatLng(
              36.315791 + (r.nextInt(i) * 0.01),
              59.538747 + (r.nextInt(i) * 0.01),
            ),
          ),
        );
      }
      await _mapController.addMarkers(markers);
    }
  }
}
