class DirectionResultsRoutesOverviewPolyline {
  String? points;

  DirectionResultsRoutesOverviewPolyline({
    this.points,
  });

  DirectionResultsRoutesOverviewPolyline.fromJson(Map<String, dynamic> json) {
    points = json["points"]?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["points"] = points;
    return data;
  }
}

class DirectionResultsRoutesLegsStepsStartLocation {
  double? lat;
  double? lng;

  DirectionResultsRoutesLegsStepsStartLocation({
    this.lat,
    this.lng,
  });

  DirectionResultsRoutesLegsStepsStartLocation.fromJson(
      Map<String, dynamic> json) {
    lat = json["lat"]?.toDouble();
    lng = json["lng"]?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["lat"] = lat;
    data["lng"] = lng;
    return data;
  }
}

class DirectionResultsRoutesLegsStepsPolyline {
  String? points;

  DirectionResultsRoutesLegsStepsPolyline({
    this.points,
  });

  DirectionResultsRoutesLegsStepsPolyline.fromJson(Map<String, dynamic> json) {
    points = json["points"]?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["points"] = points;
    return data;
  }
}

class DirectionResultsRoutesLegsStepsEndLocation {
  double? lat;
  double? lng;

  DirectionResultsRoutesLegsStepsEndLocation({
    this.lat,
    this.lng,
  });

  DirectionResultsRoutesLegsStepsEndLocation.fromJson(
      Map<String, dynamic> json) {
    lat = json["lat"]?.toDouble();
    lng = json["lng"]?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["lat"] = lat;
    data["lng"] = lng;
    return data;
  }
}

class DirectionResultsRoutesLegsStepsDuration {
  String? text;
  int? value;

  DirectionResultsRoutesLegsStepsDuration({
    this.text,
    this.value,
  });

  DirectionResultsRoutesLegsStepsDuration.fromJson(Map<String, dynamic> json) {
    text = json["text"]?.toString();
    value = json["value"]?.toInt();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["text"] = text;
    data["value"] = value;
    return data;
  }
}

class DirectionResultsRoutesLegsStepsDistance {
  String? text;
  int? value;

  DirectionResultsRoutesLegsStepsDistance({
    this.text,
    this.value,
  });

  DirectionResultsRoutesLegsStepsDistance.fromJson(Map<String, dynamic> json) {
    text = json["text"]?.toString();
    value = json["value"]?.toInt();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["text"] = text;
    data["value"] = value;
    return data;
  }
}

class DirectionResultsRoutesLegsSteps {
  DirectionResultsRoutesLegsStepsDistance? distance;
  DirectionResultsRoutesLegsStepsDuration? duration;
  DirectionResultsRoutesLegsStepsEndLocation? endLocation;
  String? htmlInstructions;
  DirectionResultsRoutesLegsStepsPolyline? polyline;
  DirectionResultsRoutesLegsStepsStartLocation? startLocation;
  String? travelMode;

  DirectionResultsRoutesLegsSteps({
    this.distance,
    this.duration,
    this.endLocation,
    this.htmlInstructions,
    this.polyline,
    this.startLocation,
    this.travelMode,
  });

  DirectionResultsRoutesLegsSteps.fromJson(Map<String, dynamic> json) {
    distance = (json["distance"] != null)
        ? DirectionResultsRoutesLegsStepsDistance.fromJson(json["distance"])
        : null;
    duration = (json["duration"] != null)
        ? DirectionResultsRoutesLegsStepsDuration.fromJson(json["duration"])
        : null;
    endLocation = (json["end_location"] != null)
        ? DirectionResultsRoutesLegsStepsEndLocation.fromJson(
            json["end_location"])
        : null;
    htmlInstructions = json["html_instructions"]?.toString();
    polyline = (json["polyline"] != null)
        ? DirectionResultsRoutesLegsStepsPolyline.fromJson(json["polyline"])
        : null;
    startLocation = (json["start_location"] != null)
        ? DirectionResultsRoutesLegsStepsStartLocation.fromJson(
            json["start_location"])
        : null;
    travelMode = json["travel_mode"]?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (distance != null) {
      data["distance"] = distance!.toJson();
    }
    if (duration != null) {
      data["duration"] = duration!.toJson();
    }
    if (endLocation != null) {
      data["end_location"] = endLocation!.toJson();
    }
    data["html_instructions"] = htmlInstructions;
    if (polyline != null) {
      data["polyline"] = polyline!.toJson();
    }
    if (startLocation != null) {
      data["start_location"] = startLocation!.toJson();
    }
    data["travel_mode"] = travelMode;
    return data;
  }
}

class DirectionResultsRoutesLegsStartLocation {
  double? lat;
  double? lng;

  DirectionResultsRoutesLegsStartLocation({
    this.lat,
    this.lng,
  });

  DirectionResultsRoutesLegsStartLocation.fromJson(Map<String, dynamic> json) {
    lat = json["lat"]?.toDouble();
    lng = json["lng"]?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["lat"] = lat;
    data["lng"] = lng;
    return data;
  }
}

class DirectionResultsRoutesLegsEndLocation {
  double? lat;
  double? lng;

  DirectionResultsRoutesLegsEndLocation({
    this.lat,
    this.lng,
  });

  DirectionResultsRoutesLegsEndLocation.fromJson(Map<String, dynamic> json) {
    lat = json["lat"]?.toDouble();
    lng = json["lng"]?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["lat"] = lat;
    data["lng"] = lng;
    return data;
  }
}

class DirectionResultsRoutesLegsDuration {
  String? text;
  int? value;

  DirectionResultsRoutesLegsDuration({
    this.text,
    this.value,
  });

  DirectionResultsRoutesLegsDuration.fromJson(Map<String, dynamic> json) {
    text = json["text"]?.toString();
    value = json["value"]?.toInt();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["text"] = text;
    data["value"] = value;
    return data;
  }
}

class DirectionResultsRoutesLegsDistance {
  String? text;
  int? value;

  DirectionResultsRoutesLegsDistance({
    this.text,
    this.value,
  });

  DirectionResultsRoutesLegsDistance.fromJson(Map<String, dynamic> json) {
    text = json["text"]?.toString();
    value = json["value"]?.toInt();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["text"] = text;
    data["value"] = value;
    return data;
  }
}

class DirectionResultsRoutesLegs {
  DirectionResultsRoutesLegsDistance? distance;
  DirectionResultsRoutesLegsDuration? duration;
  String? endAddress;
  DirectionResultsRoutesLegsEndLocation? endLocation;
  String? startAddress;
  DirectionResultsRoutesLegsStartLocation? startLocation;
  List<DirectionResultsRoutesLegsSteps?>? steps;

  // List<DirectionResultsRoutesLegsTrafficSpeedEntry?>? trafficSpeedEntry;
  // List<DirectionResultsRoutesLegsViaWaypoint?>? viaWaypoint;

  DirectionResultsRoutesLegs({
    this.distance,
    this.duration,
    this.endAddress,
    this.endLocation,
    this.startAddress,
    this.startLocation,
    this.steps,
    // this.trafficSpeedEntry,
    // this.viaWaypoint,
  });

  DirectionResultsRoutesLegs.fromJson(Map<String, dynamic> json) {
    distance = (json["distance"] != null)
        ? DirectionResultsRoutesLegsDistance.fromJson(json["distance"])
        : null;
    duration = (json["duration"] != null)
        ? DirectionResultsRoutesLegsDuration.fromJson(json["duration"])
        : null;
    endAddress = json["end_address"]?.toString();
    endLocation = (json["end_location"] != null)
        ? DirectionResultsRoutesLegsEndLocation.fromJson(json["end_location"])
        : null;
    startAddress = json["start_address"]?.toString();
    startLocation = (json["start_location"] != null)
        ? DirectionResultsRoutesLegsStartLocation.fromJson(
            json["start_location"])
        : null;
    if (json["steps"] != null) {
      final v = json["steps"];
      final arr0 = <DirectionResultsRoutesLegsSteps>[];
      v.forEach((v) {
        arr0.add(DirectionResultsRoutesLegsSteps.fromJson(v));
      });
      steps = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (distance != null) {
      data["distance"] = distance!.toJson();
    }
    if (duration != null) {
      data["duration"] = duration!.toJson();
    }
    data["end_address"] = endAddress;
    if (endLocation != null) {
      data["end_location"] = endLocation!.toJson();
    }
    data["start_address"] = startAddress;
    if (startLocation != null) {
      data["start_location"] = startLocation!.toJson();
    }
    if (steps != null) {
      final v = steps;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data["steps"] = arr0;
    }
    return data;
  }
}

class DirectionResultsRoutesBoundsSouthwest {
  double? lat;
  double? lng;

  DirectionResultsRoutesBoundsSouthwest({
    this.lat,
    this.lng,
  });

  DirectionResultsRoutesBoundsSouthwest.fromJson(Map<String, dynamic> json) {
    lat = json["lat"]?.toDouble();
    lng = json["lng"]?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["lat"] = lat;
    data["lng"] = lng;
    return data;
  }
}

class DirectionResultsRoutesBoundsNortheast {
  double? lat;
  double? lng;

  DirectionResultsRoutesBoundsNortheast({
    this.lat,
    this.lng,
  });

  DirectionResultsRoutesBoundsNortheast.fromJson(Map<String, dynamic> json) {
    lat = json["lat"]?.toDouble();
    lng = json["lng"]?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["lat"] = lat;
    data["lng"] = lng;
    return data;
  }
}

class DirectionResultsRoutesBounds {
  DirectionResultsRoutesBoundsNortheast? northeast;
  DirectionResultsRoutesBoundsSouthwest? southwest;

  DirectionResultsRoutesBounds({
    this.northeast,
    this.southwest,
  });

  DirectionResultsRoutesBounds.fromJson(Map<String, dynamic> json) {
    northeast = (json["northeast"] != null)
        ? DirectionResultsRoutesBoundsNortheast.fromJson(json["northeast"])
        : null;
    southwest = (json["southwest"] != null)
        ? DirectionResultsRoutesBoundsSouthwest.fromJson(json["southwest"])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (northeast != null) {
      data["northeast"] = northeast!.toJson();
    }
    if (southwest != null) {
      data["southwest"] = southwest!.toJson();
    }
    return data;
  }
}

class DirectionResultsRoutes {
  DirectionResultsRoutesBounds? bounds;
  String? copyrights;
  List<DirectionResultsRoutesLegs?>? legs;
  DirectionResultsRoutesOverviewPolyline? overviewPolyline;
  String? summary;

  // List<DirectionResultsRoutesWarnings?>? warnings;
  // List<DirectionResultsRoutesWaypointOrder?>? waypointOrder;

  DirectionResultsRoutes({
    this.bounds,
    this.copyrights,
    this.legs,
    this.overviewPolyline,
    this.summary,
    // this.warnings,
    // this.waypointOrder,
  });

  DirectionResultsRoutes.fromJson(Map<String, dynamic> json) {
    bounds = (json["bounds"] != null)
        ? DirectionResultsRoutesBounds.fromJson(json["bounds"])
        : null;
    copyrights = json["copyrights"]?.toString();
    if (json["legs"] != null) {
      final v = json["legs"];
      final arr0 = <DirectionResultsRoutesLegs>[];
      v.forEach((v) {
        arr0.add(DirectionResultsRoutesLegs.fromJson(v));
      });
      legs = arr0;
    }
    overviewPolyline = (json["overview_polyline"] != null)
        ? DirectionResultsRoutesOverviewPolyline.fromJson(
            json["overview_polyline"])
        : null;
    summary = json["summary"]?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (bounds != null) {
      data["bounds"] = bounds!.toJson();
    }
    data["copyrights"] = copyrights;
    if (legs != null) {
      final v = legs;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data["legs"] = arr0;
    }
    if (overviewPolyline != null) {
      data["overview_polyline"] = overviewPolyline!.toJson();
    }
    data["summary"] = summary;
    return data;
  }
}

class DirectionResultsGeocodedWaypoints {
  String? geocoderStatus;
  String? placeId;
  List<String?>? types;

  DirectionResultsGeocodedWaypoints({
    this.geocoderStatus,
    this.placeId,
    this.types,
  });

  DirectionResultsGeocodedWaypoints.fromJson(Map<String, dynamic> json) {
    geocoderStatus = json["geocoder_status"]?.toString();
    placeId = json["place_id"]?.toString();
    if (json["types"] != null) {
      final v = json["types"];
      final arr0 = <String>[];
      v.forEach((v) {
        arr0.add(v.toString());
      });
      types = arr0;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["geocoder_status"] = geocoderStatus;
    data["place_id"] = placeId;
    if (types != null) {
      final v = types;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v);
      });
      data["types"] = arr0;
    }
    return data;
  }
}

class DirectionResults {
  List<DirectionResultsGeocodedWaypoints?>? geocodedWaypoints;
  List<DirectionResultsRoutes?>? routes;
  String? status;

  DirectionResults({
    this.geocodedWaypoints,
    this.routes,
    this.status,
  });

  DirectionResults.fromJson(Map<String, dynamic> json) {
    if (json["geocoded_waypoints"] != null) {
      final v = json["geocoded_waypoints"];
      final arr0 = <DirectionResultsGeocodedWaypoints>[];
      v.forEach((v) {
        arr0.add(DirectionResultsGeocodedWaypoints.fromJson(v));
      });
      geocodedWaypoints = arr0;
    }
    if (json["routes"] != null) {
      final v = json["routes"];
      final arr0 = <DirectionResultsRoutes>[];
      v.forEach((v) {
        arr0.add(DirectionResultsRoutes.fromJson(v));
      });
      routes = arr0;
    }
    status = json["status"]?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (geocodedWaypoints != null) {
      final v = geocodedWaypoints;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data["geocoded_waypoints"] = arr0;
    }
    if (routes != null) {
      final v = routes;
      final arr0 = [];
      v!.forEach((v) {
        arr0.add(v!.toJson());
      });
      data["routes"] = arr0;
    }
    data["status"] = status;
    return data;
  }
}
