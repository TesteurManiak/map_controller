import 'package:flutter_map/flutter_map.dart';
import 'package:geojson/geojson.dart';
import 'package:geopoint/geopoint.dart';
import 'package:meta/meta.dart';

import '../models.dart';

/// State of the lines on the map
class LinesState {
  /// Default contructor
  LinesState({@required this.notify}) : assert(notify != null);

  /// The notify function
  final Function notify;

  final Map<String, Polyline> _namedLines = {};

  /// The named lines on the map
  Map<String, Polyline> get namedLines => _namedLines;

  /// The lines present on the map
  List<Polyline> get lines => _namedLines.values.toList();

  /// Add a line on the map
  Future<void> addLine({@required String name, @required Polyline line}) async {
    _namedLines[name] = line;
    notify("updateLines", _namedLines[name], addLine,
        MapControllerChangeType.lines);
  }

  /// Remove a line from the map
  Future<void> removeLine(String name) async {
    if (_namedLines.containsKey(name)) {
      _namedLines.remove(name);
      notify("updateLines", name, removeLine, MapControllerChangeType.lines);
    }
  }

  /// Export all lines to a [GeoJsonFeature] with geometry
  /// type [GeoJsonMultiLine]
  GeoJsonFeature<GeoJsonMultiLine> toGeoJsonFeatures() {
    if (namedLines.isEmpty) {
      return null;
    }
    final multiLine = GeoJsonMultiLine(name: "map_lines");
    for (final k in namedLines.keys) {
      final polyline = namedLines[k];
      final line = GeoJsonLine()..name = k;
      final geoSerie = GeoSerie(name: line.name, type: GeoSerieType.line);
      for (final point in polyline.points) {
        geoSerie.geoPoints.add(
            GeoPoint(latitude: point.latitude, longitude: point.longitude));
      }
      line.geoSerie = geoSerie;
      multiLine.lines.add(line);
    }
    final feature = GeoJsonFeature<GeoJsonMultiLine>()
      ..type = GeoJsonFeatureType.multiline
      ..geometry = multiLine
      ..properties = <String, dynamic>{"name": "map_lines"};
    return feature;
  }
}
