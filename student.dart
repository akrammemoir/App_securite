import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'functions.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as map_tool;

class StudentPage extends StatefulWidget {
  const StudentPage({Key? key}) : super(key: key);

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  bool InArea = true;
  var lat;
  var long;
  late StreamSubscription<Position> _positionStreamSubscription;
  late Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(36.813020, 7.716708),
    zoom: 15.45,
  );
  final Set<Marker> _markers = {
    const Marker(
      markerId: MarkerId("P1"),
      position: LatLng(36.816118, 7.722268),
      infoWindow: InfoWindow(title: "Poste 1"),
    ),
    const Marker(
      markerId: MarkerId("P2"),
      position: LatLng(36.813629, 7.720660),
      infoWindow: InfoWindow(title: "poste 2"),
    ),
    const Marker(
      markerId: MarkerId("P3"),
      position: LatLng(36.816972, 7.711950),
      infoWindow: InfoWindow(title: "poste 3"),
    ),
    const Marker(
      markerId: MarkerId("P3"),
      position: LatLng(36.816972, 7.711950),
      infoWindow: InfoWindow(title: "poste 3"),
    ),
  };

  Future<void> _sendAlert(Position position) async {
    // TODO: Send the alert and the current position to the agent
    print(
        'Alert sent with position: ${position.latitude}, ${position.longitude}');
  }

  List<LatLng> PolygonPoints = const [
    LatLng(36.815910, 7.724470),
    LatLng(36.812793, 7.722020),
    LatLng(36.809735, 7.719193),
    LatLng(36.807642, 7.717655),
    LatLng(36.809915, 7.713009),
    LatLng(36.812101, 7.710140),
    LatLng(36.816763, 7.710976),
    LatLng(36.817888, 7.713401),
    LatLng(36.817129, 7.714764),
    LatLng(36.817655, 7.717226),
    LatLng(36.816458, 7.721240),
    LatLng(36.816214, 7.722401),
  ];

  void checkLocation(LatLng pointLatLng) {
    List<map_tool.LatLng> convPlg = PolygonPoints.map(
      (point) => map_tool.LatLng(point.latitude, point.longitude),
    ).toList();
    setState(() {
      InArea = map_tool.PolygonUtil.containsLocation(
          map_tool.LatLng(pointLatLng.latitude, pointLatLng.longitude),
          convPlg,
          false);
    });
  }

  void _onAlertButtonPressed() async {
    // Get the current position of the device
    Position currentPosition = await Geolocator.getCurrentPosition();
    lat = currentPosition.latitude;
    long = currentPosition.longitude;

    // Add a marker to the map
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId("alert"),
          position: LatLng(lat, long),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    });

    // Send the alert and the current position to the agent
    _sendAlert(currentPosition);
  }

  changeMarker(newlat, newlong) {
    _markers.remove(Marker(
      markerId: MarkerId("alert"),
    ));
    _markers.add(Marker(
      markerId: MarkerId("alert"),
      position: LatLng(newlat, newlong),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      onDrag: (value) {
        checkLocation(value);
      },
    ));
    setState(() {});
  }

  @override
  void initState() {
    _positionStreamSubscription =
        Geolocator.getPositionStream().listen((Position? position) {
      changeMarker(position?.latitude, position?.longitude);
    });
    _onAlertButtonPressed();
    super.initState();
  }

  @override
  void dispose() {
    _positionStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Univ sécurité'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications),
          ),
        ],
        backgroundColor: const Color.fromARGB(255, 25, 17, 87),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: Column(children: [
          const UserAccountsDrawerHeader(
            currentAccountPicture: CircleAvatar(backgroundColor: Colors.black),
            accountName: Text("Username"),
            accountEmail: Text("nom prenom"),
          ),
          ListTile(
            title: const Text(
              "Settings",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            leading: const Icon(Icons.settings),
            onTap: () {},
          ),
          ListTile(
            title: const Text(
              "history",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            leading: const Icon(Icons.history),
            onTap: () {},
          ),
          const Spacer(),
          ListTile(
              title: const Text(
                "logout",
                style: TextStyle(fontSize: 20, color: Colors.red),
              ),
              leading: const Icon(
                Icons.logout,
                color: Colors.red,
              ),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
              }),
        ]),
      ),
      body: Container(
        child: GoogleMap(
          mapType: MapType.satellite,
          initialCameraPosition: _kGooglePlex,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          markers: _markers,
          polygons: {
            Polygon(
              polygonId: PolygonId("1"),
              points: PolygonPoints,
              fillColor: Colors.blue.withOpacity(0.15),
              strokeWidth: 5,
              strokeColor: Color.fromARGB(255, 39, 26, 91),
            ),
          },
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 70,
        child: BottomAppBar(
          color: const Color.fromARGB(255, 25, 17, 87),
          shape: const CircularNotchedRectangle(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 80,
                height: 40,
                child: TextButton.icon(
                  onPressed: () {
                    launchDialer();
                  },
                  icon: const Icon(Icons.call, color: Colors.white),
                  label:
                      const Text('Call', style: TextStyle(color: Colors.white)),
                ),
              ),
              SizedBox(
                width: 80,
                height: 40,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true)
                        .pushNamed('/declaration');
                  },
                  icon: const Icon(Icons.message, color: Colors.white),
                  label: const Text('Declaration',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 80,
        height: 80,
        child: FloatingActionButton(
          backgroundColor: const Color.fromARGB(255, 218, 58, 40),
          heroTag: 'customSize',
          onPressed: () {},
          child: const Text(
            "Alert",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
