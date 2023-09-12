import 'dart:ffi';
import 'dart:math';

import 'package:app/const.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class MapboxWidget extends StatefulWidget {
  final CameraPosition? cameraPosition;
  final MapLoadCallback? onMapLoad;
  final List<MapLayer> layers;

  const MapboxWidget({
    super.key,
    this.cameraPosition,
    this.onMapLoad,
    required this.layers,
  });

  @override
  State<MapboxWidget> createState() => _MapboxWidgetState();
}

class _MapboxWidgetState extends State<MapboxWidget> {
  final MapController _mapController = MapController();

  _onMapCreated(MapboxMapController controller) async {
    await _mapController.init(
      controller,
      widget.layers,
    );
    widget.onMapLoad?.call(_mapController);
  }

  @override
  Widget build(BuildContext context) {
    return MapboxMap(
      accessToken: secretToken,
      onMapCreated: _onMapCreated,
      onStyleLoadedCallback: _mapController.loadSources,
      initialCameraPosition: widget.cameraPosition ??
          const CameraPosition(target: LatLng(0.0, 0.0)),
    );
  }
}

enum MapLayerType { raster, vector }

class MapLayer {
  final String name;
  final String address;
  final MapLayerType type;

  MapLayer(this.name, this.address, this.type);
}

class MapMarker {
  final String image;
  final LatLng point;
  final int id;

  MapMarker(this.id, this.image, this.point);
}

typedef MapLoadCallback = void Function(MapController mapController);

class MapController {
  late MapboxMapController _mapController;

  final String rasterSourceName = 'base_source';
  final String vectorSourceName = 'symbol_source';

  final Map<String, dynamic> _features = {
    "type": "FeatureCollection",
    "features": []
  };

  List<MapLayer> _layers = [];

  Future<void> loadSources() async {
    await _mapController.addSource(
      rasterSourceName,
      const RasterSourceProperties(
        tiles: ['https://tile.radargps.org/styles/radar/{z}/{x}/{y}@2x.png'],
      ),
    );
    //
    // await _mapController.addSource(
    //   vectorSourceName,
    //   const VectorSourceProperties(
    //     tiles: ['https://tile.radarcloud.ir/data/openmaptiles/{z}/{x}/{y}.pbf'],
    //   ),
    // );
    // await _mapController.addLayer(
    //     vectorSourceName,
    //     "contour",
    //     LineLayerProperties(
    //       lineColor: "#ff69b4",
    //       lineWidth: 1,
    //       lineCap: "round",
    //       lineJoin: "round",
    //     ),
    //     sourceLayer: "contour");
    await _mapController.addRasterLayer(rasterSourceName, 'layerId', RasterLayerProperties());
  }

  Future<void> init(
    MapboxMapController mapController,
    List<MapLayer> layers,
  ) async {
    _mapController = mapController;
    _layers = layers;
  }

  Future<void> switchLayer(String layerName) async {
    MapLayer? layer =
        _layers.firstWhereOrNull((element) => element.name == layerName);
  }

  Future<void> addImageAssets(Map<String, String> assetsImages) async {
    for (var image in assetsImages.entries) {
      var byteData = (await rootBundle.load(image.value)).buffer.asUint8List();
      await _mapController.addImage(image.key, byteData);
    }
  }

  Future<void> addMarker(MapMarker marker) async {
    await _mapController.addSymbol(
      SymbolOptions(
        geometry: marker.point,
        iconImage: marker.image,
        iconSize: 2,
      ),
    );
  }

  Future<void> addMarkers(List<MapMarker> markers) async {
    await _mapController.addSymbols(
      markers
          .map(
            (e) => SymbolOptions(
              geometry: e.point,
              iconImage: e.image,
              iconSize: 2,
            ),
          )
          .toList(),
    );
  }
}
