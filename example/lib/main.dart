import 'package:flutter/material.dart';
import 'package:dart_geodatakit/dart_geodatakit.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() => runApp(const GeoDataApp());

class GeoDataApp extends StatelessWidget {
  const GeoDataApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GeoDataKit Example',
      home: const GeoDataHomePage(),
    );
  }
}

class GeoDataHomePage extends StatefulWidget {
  const GeoDataHomePage({super.key});

  @override
  State<GeoDataHomePage> createState() => _GeoDataHomePageState();
}

class _GeoDataHomePageState extends State<GeoDataHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GeoDataKit Example')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
                onPressed: _loadGeoJSON, child: const Text('Load GeoJSON')),
            ElevatedButton(
                onPressed: _loadShapefile, child: const Text('Load Shapefile')),
            ElevatedButton(
                onPressed: _loadGeoPackage,
                child: const Text('Load GeoPackage')),
          ],
        ),
      ),
    );
  }

  Future<void> _loadGeoJSON() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['geojson']);
    if (result?.files.single.path == null) return;
    final handler = GeoJSONHandler();
    await handler.parseGeoJSONFile(result!.files.single.path!);
    _showMessage('Loaded ${handler.features.length} features from GeoJSON');
  }

  Future<void> _loadShapefile() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['zip', 'shp']);
    if (result?.files.single.path == null) return;
    try {
      final handler = ShapefileHandler();
      await handler.readShapefile(result!.files.single.path!);
      _showMessage('Loaded ${handler.features.length} features from Shapefile');
    } catch (e) {
      _showMessage('Error loading Shapefile: $e');
    }
  }

  Future<void> _loadGeoPackage() async {
    if (kIsWeb) {
      _showMessage('GeoPackage not supported on Web');
      return;
    }
    final result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['gpkg']);
    if (result?.files.single.path == null) return;
    try {
      final handler = GeoPackageHandler()
        ..openGeoPackage(result!.files.single.path!)
        ..readFeatures()
        ..closeGeoPackage();
      _showMessage(
          'Loaded ${handler.features.length} features from GeoPackage');
    } catch (e) {
      _showMessage('Error loading GeoPackage: $e');
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
