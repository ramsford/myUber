import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:rider_app/AllScreens/search.screen.dart';
import 'package:rider_app/Assistants/assistant.methods.dart';
import 'package:rider_app/CustomWidgets/divider.dart';
import 'package:rider_app/CustomWidgets/progressDialog.dart';
import 'package:rider_app/DataHandler/appData.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rider_app/Models/direction.details.model.dart';

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
          Positioned(
              top: 38,
              left: 22,
              child: GestureDetector(
                onTap: () {
                  if (drawerOpen) {
                    scaffoldKey.currentState.openDrawer();
                  }
                  else {
                    resetApp();
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black,
                            blurRadius: 6,
                            spreadRadius: 0.5,
                            offset: Offset(0.7, 0.7)),
                      ]),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon((drawerOpen) ? Icons.menu : Icons.close, color: Colors.black),
                    radius: 20,
                  ),
                ),
              )),
          Positioned(
            right: 0,
            left: 0,
            bottom: 0,
            child: AnimatedSize(
              vsync: this,
              curve: Curves.bounceIn,
              duration: Duration(milliseconds: 160),
              child: Container(
                height: searchContainerHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 16,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 21, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 6),
                      Text("Bonjour,", style: TextStyle(fontSize: 12)),
                      Text("Où allez-vous ?",
                          style:
                              TextStyle(fontSize: 20, fontFamily: "Brand-Bold")),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: () async {
                          var res = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SearchScreen()));
                          if (res == "obtainDirection") {
                            displayRideDetailsContainer();
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black54,
                                blurRadius: 6,
                                spreadRadius: 0.5,
                                offset: Offset(0.7, 0.7),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  color: Colors.blueAccent,
                                ),
                                SizedBox(width: 10),
                                Text("Chercher votre destination")
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      Row(
                        children: [
                          Icon(Icons.home, color: Colors.grey),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Provider.of<AppData>(context).pickUpLocation !=
                                        null
                                    ? Provider.of<AppData>(context)
                                        .pickUpLocation
                                        .placeName
                                    : "Ajouter votre domicile",
                              ),
                              SizedBox(height: 4),
                              Text("Votre adresse",
                                  style: TextStyle(
                                      color: Colors.black54, fontSize: 12)),
                            ],
                          )
                        ],
                      ),
                      SizedBox(height: 10),
                      DividerWidget(),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.work, color: Colors.grey),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Ajouter la destination"),
                              SizedBox(height: 4),
                              Text("Votre adresse de destination",
                                  style: TextStyle(
                                      color: Colors.black54, fontSize: 12)),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSize(
              vsync: this,
              curve: Curves.bounceIn,
              duration: Duration(milliseconds: 160),
              child: Container(
                height: rideDetailsContainerHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0), topRight: Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 16,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 17),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        color: Colors.black,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Image.asset("assets/images/taxi.png", height: 70, width: 80),
                              SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Voiture", style: TextStyle(fontSize: 18, fontFamily: "Brand-Bold", color: Colors.white),
                                  ),
                                  Text(
                                      ((tripDirectionDetails != null) ? tripDirectionDetails.distanceText : '') , style: TextStyle(fontSize: 16, color: Colors.white)),
                                ],
                              ),
                              Expanded(child: Container()),
                              Text((tripDirectionDetails != null) ? '\$${AssistantMethods.calculateFares(tripDirectionDetails)}' : '', style: TextStyle(fontSize: 16, fontFamily: "Brand-Bold",color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Icon(FontAwesomeIcons.moneyCheckAlt, size: 18, color: Colors.black),
                            SizedBox(width: 16),
                            Text("Prix", style: TextStyle(color: Colors.black),),
                            SizedBox(width: 6),
                            Icon(Icons.keyboard_arrow_down, color: Colors.black, size: 16),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: TextButton(
                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.black)),
                          onPressed: () {},
                          child: Padding(
                            padding: EdgeInsets.all(17),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Requests", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                                Icon(FontAwesomeIcons.taxi, color: Colors.white, size: 26),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
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
