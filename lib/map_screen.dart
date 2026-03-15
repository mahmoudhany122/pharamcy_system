import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'dart:async';
import 'dart:math' as math;

// ✅ نموذج للمكان
class PlaceModel {
  final String id;
  final String name;
  final LatLng location;
  final String description;
  final IconData icon;

  PlaceModel({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    this.icon = Icons.location_on,
  });
}

class UberLikeMapScreen extends StatefulWidget {
  @override
  State<UberLikeMapScreen> createState() => _UberLikeMapScreenState();
}

class _UberLikeMapScreenState extends State<UberLikeMapScreen> {
  late MapController mapController;

  // ✅ الموقع الحالي (نقطة البداية)
  LatLng _currentLocation = LatLng(30.0444, 31.2357);

  // ✅ الوجهة المختارة
  LatLng? _destination;
  String? _destinationName;

  // ✅ قائمة الأماكن المتاحة
  List<PlaceModel> _availablePlaces = [
    PlaceModel(
      id: '1',
      name: 'محطة القاهرة',
      location: LatLng(30.0550, 31.2400),
      description: 'محطة القطار الرئيسية',
      icon: Icons.train,
    ),
    PlaceModel(
      id: '2',
      name: 'مول سيتي ستارز',
      location: LatLng(30.0600, 31.2450),
      description: 'مركز تسوق كبير',
      icon: Icons.shopping_basket_outlined,
    ),
    PlaceModel(
      id: '3',
      name: 'جامعة القاهرة',
      location: LatLng(30.0350, 31.2300),
      description: 'الحرم الجامعي',
      icon: Icons.school,
    ),
    PlaceModel(
      id: '4',
      name: 'مستشفى عين شمس',
      location: LatLng(30.0500, 31.2250),
      description: 'مستشفى حكومي',
      icon: Icons.local_hospital,
    ),
    PlaceModel(
      id: '5',
      name: 'مطار القاهرة',
      location: LatLng(30.1219, 31.4059),
      description: 'المطار الدولي',
      icon: Icons.flight,
    ),
  ];

  // ✅ التتبع الحي
  late StreamSubscription<Position> _positionStream;
  bool _isTracking = false;

  // ✅ المسافة والوقت
  double _distance = 0;
  String _estimatedTime = '--:--';

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    _requestLocationPermission();
  }

  // ✅ حساب المسافة بين نقطتين
  double _calculateDistance(LatLng from, LatLng to) {
    const double earthRadius = 6371; // كم
    final lat1 = from.latitude * math.pi / 180;
    final lat2 = to.latitude * math.pi / 180;
    final deltaLat = (to.latitude - from.latitude) * math.pi / 180;
    final deltaLng = (to.longitude - from.longitude) * math.pi / 180;

    final a = math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(deltaLng / 2) *
            math.sin(deltaLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  // ✅ حساب الوقت المتوقع (سرعة متوسطة 40 كم/س)
  String _estimateTime(double distanceKm) {
    const averageSpeed = 40.0; // كم/س
    final hours = distanceKm / averageSpeed;
    final minutes = (hours * 60).toInt();
    if (minutes < 60) {
      return '$minutes دقيقة';
    } else {
      final h = minutes ~/ 60;
      final m = minutes % 60;
      return '$h س $m د';
    }
  }

  // ✅ طلب الـ Permission
  Future<void> _requestLocationPermission() async {
    final status = await Geolocator.requestPermission();
    if (status == LocationPermission.denied ||
        status == LocationPermission.deniedForever) {
      return;
    }
    _getUserLocation();
  }

  // ✅ الحصول على الموقع الحالي
  Future<void> _getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });

      mapController.move(_currentLocation, 14);
    } catch (e) {
      print('Error: $e');
    }
  }

  // ✅ تحريك الكاميرا
  void _moveCamera(LatLng location, double zoom) {
    mapController.move(location, zoom);
  }

  // ✅ اختيار وجهة
  void _selectDestination(PlaceModel place) {
    setState(() {
      _destination = place.location;
      _destinationName = place.name;

      // حساب المسافة
      _distance = _calculateDistance(_currentLocation, place.location);
      _estimatedTime = _estimateTime(_distance);
    });

    // تحريك الكاميرا لتظهر البداية والنهاية
    _fitBoundsToShowBoth();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم اختيار الوجهة: ${place.name}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // ✅ جعل الخريطة تظهر البداية والنهاية معاً
  void _fitBoundsToShowBoth() {
    if (_destination != null) {
      final minLat = math.min(_currentLocation.latitude, _destination!.latitude);
      final maxLat =
      math.max(_currentLocation.latitude, _destination!.latitude);
      final minLng =
      math.min(_currentLocation.longitude, _destination!.longitude);
      final maxLng =
      math.max(_currentLocation.longitude, _destination!.longitude);

      final centerLat = (minLat + maxLat) / 2;
      final centerLng = (minLng + maxLng) / 2;

      mapController.move(LatLng(centerLat, centerLng), 12);
    }
  }

  // ✅ بدء الرحلة (التتبع الحي)
  void _startTrip() {
    if (_destination == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('اختر وجهة أولاً'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isTracking = true;
    });

    _positionStream = Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);

        // حساب المسافة المتبقية
        _distance =
            _calculateDistance(_currentLocation, _destination!);
        _estimatedTime = _estimateTime(_distance);
      });

      // تحديث الخريطة
      _fitBoundsToShowBoth();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('بدأت الرحلة - ${_destinationName}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // ✅ إنهاء الرحلة
  void _endTrip() {
    setState(() {
      _isTracking = false;
      _destination = null;
      _destinationName = null;
      _distance = 0;
    });

    _positionStream.cancel();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('انتهت الرحلة'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // ✅ الـ URL حسب نوع الخريطة
  String _getTileUrl() {
    return 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png';
  }

  @override
  void dispose() {
    if (_isTracking) {
      _positionStream.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تطبيق نقل - مثل Uber'),
        backgroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // ✅ الخريطة
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: _currentLocation,
              initialZoom: 14,
            ),
            children: [
              TileLayer(
                urlTemplate: _getTileUrl(),
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.example.zamalek_fans_app',
              ),
              // ✅ رسم الخط من البداية للنهاية
              if (_destination != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [_currentLocation, _destination!],
                      color: Colors.blue,
                      strokeWidth: 5,
                      isDotted: false,
                    ),
                  ],
                ),
              // ✅ عرض الموقع الحالي والوجهة
              MarkerLayer(
                markers: [
                  // 🟢 موقعك الحالي
                  Marker(
                    point: _currentLocation,
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  // 🔴 الوجهة (لو اختارت)
                  if (_destination != null)
                    Marker(
                      point: _destination!,
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.5),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // ✅ بطاقة البحث عن الوجهة (أعلى)
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // البداية
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(Icons.my_location, color: Colors.green, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'موقعك الحالي',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '${_currentLocation.latitude.toStringAsFixed(4)}, ${_currentLocation.longitude.toStringAsFixed(4)}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1),
                  // الوجهة
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: GestureDetector(
                      onTap: () {
                        _showPlacesBottomSheet();
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: _destination != null ? Colors.red : Colors.grey,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'اختر وجهة',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  _destinationName ?? 'اضغط لاختيار',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: _destination != null
                                        ? Colors.black
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ✅ بطاقة معلومات الرحلة (أسفل)
          if (_destination != null)
            Positioned(
              bottom: 20,
              left: 10,
              right: 10,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                    ),
                  ],
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // الوجهة والمسافة
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _destinationName!,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              '${_distance.toStringAsFixed(2)} كم',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _estimatedTime,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'الوقت المتوقع',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    // الأزرار
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isTracking ? null : _startTrip,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              _isTracking ? Colors.grey : Colors.green,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              _isTracking ? 'جارية الآن' : 'ابدأ الرحلة',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        if (_isTracking) ...[
                          SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _endTrip,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'إنهاء',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // ✅ زر موقعي الحالي
          Positioned(
            right: 15,
            bottom: _destination != null ? 280 : 20,
            child: FloatingActionButton(
              mini: true,
              onPressed: () {
                _moveCamera(_currentLocation, 14);
              },
              backgroundColor: Colors.blue,
              child: Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ عرض قائمة الأماكن
  void _showPlacesBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'اختر وجهتك',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: _availablePlaces.length,
                itemBuilder: (context, index) {
                  final place = _availablePlaces[index];
                  final distance = _calculateDistance(_currentLocation, place.location);

                  return ListTile(
                    leading: Icon(place.icon, color: Colors.blue),
                    title: Text(place.name),
                    subtitle: Text('${distance.toStringAsFixed(2)} كم'),
                    onTap: () {
                      _selectDestination(place);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}