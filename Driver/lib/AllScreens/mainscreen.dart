import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:uber_driver/AllScreens/search.screen.dart';
import 'package:uber_driver/Assistants/assistant.methods.dart';
import 'package:uber_driver/CustomWidgets/divider.dart';
import 'package:uber_driver/CustomWidgets/progressDialog.dart';
import 'package:uber_driver/DataHandler/appData.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:uber_driver/Models/direction.details.model.dart';

class MainScreen extends StatefulWidget {
  static const String idScreen = "mainScreen";
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin{
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  DirectionDetails tripDirectionDetails;

  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polylineSet = {};
  Position currentPosition;
  var geoLocator = Geolocator();
  double bottomPaddingOfMap = 0;
  Set<Marker> marker = {};
  Set<Circle> circle = {};

  double rideDetailsContainerHeight = 0;
  double searchContainerHeight = 300;
  bool drawerOpen = true;

  resetApp() {
    setState(() {
      drawerOpen = true;
      searchContainerHeight = 300;
      rideDetailsContainerHeight = 0;
      bottomPaddingOfMap = 230;
      polylineSet.clear();
      pLineCoordinates.clear();
      marker.clear();
      circle.clear();
    });
    locatePosition();
  }

  void displayRideDetailsContainer() async {
    await getPlaceDirection();

    setState(() {
      searchContainerHeight = 0;
      rideDetailsContainerHeight = 240;
      bottomPaddingOfMap = 0;
      drawerOpen = false;
    });
  }

  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng latlangPosition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition =
        CameraPosition(target: latlangPosition, zoom: 14);
    newGoogleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    String address =
        await AssistantMethods.searchCoordinateAddress(position, context);
    print("this is your address" + address);
  }

  GoogleMapController newGoogleMapController;
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: scaffoldKey,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        title: Text("Uber", style: TextStyle(color: Colors.black)),
      ),
      drawer: Container(
        color: Colors.white,
        width: 255,
        child: ListView(
          children: [
            Container(
              height: 165,
              child: DrawerHeader(
                decoration: BoxDecoration(color: Colors.white),
                child: Row(children: [
                  Image.asset("assets/images/user_icon.png",
                      height: 65, width: 65),
                  SizedBox(width: 16),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Nom du profil",
                          style: TextStyle(
                              fontSize: 16, fontFamily: "Brand-Bold")),
                      SizedBox(height: 6),
                      Text("Voir le profil"),
                    ],
                  )
                ]),
              ),
            ),
            DividerWidget(),
            SizedBox(height: 12),
            ListTile(
              leading: Icon(Icons.history),
              title: Text("Historique", style: TextStyle(fontSize: 15)),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Voir profil", style: TextStyle(fontSize: 15)),
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text("À propos", style: TextStyle(fontSize: 15)),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: _kGooglePlex,
            myLocationEnabled: true,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            polylines: polylineSet,
            markers: marker,
            circles: circle,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;
              setState(() {
                bottomPaddingOfMap = 300;
              });
              locatePosition();
            },
          ),
        ],
      ),
    );
  }

  Future<void> getPlaceDirection() async {
    var initialPosition =
        Provider.of<AppData>(context, listen: false).pickUpLocation;
    var finalPosition =
        Provider.of<AppData>(context, listen: false).dropOffLocation;
    var pickUpLatLng =
        LatLng(initialPosition.latitude, initialPosition.longitude);
    var dropOffLatLng = LatLng(finalPosition.latitude, finalPosition.longitude);
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            ProgressDialog(message: "Patientez s'il-vous-plaît..."));
    var details =
        await AssistantMethods.getDirectionDetails(pickUpLatLng, dropOffLatLng);
    setState(() {
      tripDirectionDetails = details;
    });

    Navigator.pop(context);
    print("This is Encoded Points ::");
    print(details.encodedPoints);
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodePolylinePointsResult =
        polylinePoints.decodePolyline(details.encodedPoints);

    pLineCoordinates.clear();

    if (decodePolylinePointsResult.isNotEmpty) {
      decodePolylinePointsResult.forEach((PointLatLng pointLatLng) {
        pLineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }
    polylineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
        color: Colors.pink,
        polylineId: PolylineId("PolylineID"),
        jointType: JointType.round,
        points: pLineCoordinates,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );
      polylineSet.add(polyline);
    });
    LatLngBounds latLngBounds;
    if (pickUpLatLng.latitude > dropOffLatLng.latitude &&
        pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds =
          LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);
    } else if (pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude),
          northeast: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude));
    } else if (pickUpLatLng.latitude > dropOffLatLng.latitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(dropOffLatLng.latitude, dropOffLatLng.longitude),
          northeast: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude));
    } else {
      latLngBounds =
          LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);
    }
    newGoogleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));
    Marker pickupLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow:
          InfoWindow(title: initialPosition.placeName, snippet: "Départ"),
      position: pickUpLatLng,
      markerId: MarkerId("pickUpId"),
    );
    Marker dropOffLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow:
          InfoWindow(title: finalPosition.placeName, snippet: "Destination"),
      position: dropOffLatLng,
      markerId: MarkerId("droOffId"),
    );

    setState(() {
      marker.add(pickupLocMarker);
      marker.add(dropOffLocMarker);
    });

    Circle pickUpLocCircle = Circle(
      fillColor: Colors.black,
      center: pickUpLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.black,
      circleId: CircleId("pickUpId"),
    );
    Circle dropOffLocCircle = Circle(
      fillColor: Colors.red,
      center: dropOffLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.red,
      circleId: CircleId("dropOffId"),
    );
    setState(() {
      circle.add(pickUpLocCircle);
      circle.add(dropOffLocCircle);
    });
  }
}
