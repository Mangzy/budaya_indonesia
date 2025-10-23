import 'dart:io';
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

class ArWearBodyArPage extends StatefulWidget {
  final String title;
  final String? iosSrcUrl; // remote USDZ url
  const ArWearBodyArPage({super.key, required this.title, this.iosSrcUrl});

  @override
  State<ArWearBodyArPage> createState() => _ArWearBodyArPageState();
}

class _ArWearBodyArPageState extends State<ArWearBodyArPage> {
  ARKitController? _controller;
  String? _localUsdzPath;
  String? _error;

  @override
  void initState() {
    super.initState();
    _prepareModel();
  }

  Future<void> _prepareModel() async {
    final url = widget.iosSrcUrl;
    if (url == null || url.isEmpty) {
      setState(() => _error = 'Model .usdz untuk iOS belum tersedia.');
      return;
    }
    try {
      final resp = await http.get(Uri.parse(url));
      if (resp.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/garment.usdz';
        final file = File(path);
        await file.writeAsBytes(resp.bodyBytes, flush: true);
        setState(() => _localUsdzPath = path);
      } else {
        setState(() => _error = 'Gagal mengunduh USDZ (${resp.statusCode}).');
      }
    } catch (e) {
      setState(() => _error = 'Gagal mengunduh USDZ: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _error != null
          ? Center(child: Text(_error!))
          : ARKitSceneView(
              configuration: ARKitConfiguration.bodyTracking,
              onARKitViewCreated: (c) {
                _controller = c;
                _controller!.onAddNodeForAnchor = _onAddNodeForAnchor;
                _controller!.onUpdateNodeForAnchor = _onUpdateNodeForAnchor;
              },
            ),
    );
  }

  void _onAddNodeForAnchor(ARKitAnchor anchor) {
    if (anchor is ARKitBodyAnchor) {
      if (_localUsdzPath == null) return;
      final node = ARKitReferenceNode(url: _localUsdzPath!, scale: Vector3(1, 1, 1));
      _controller!.add(node, parentNodeName: anchor.nodeName);
    }
  }

  void _onUpdateNodeForAnchor(ARKitAnchor anchor) {
    // We rely on parenting to the body anchor; ARKit updates node transform.
  }
}
