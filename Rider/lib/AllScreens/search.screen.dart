import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rider_app/Assistants/requests.assistant.dart';
import 'package:rider_app/CustomWidgets/divider.dart';
import 'package:rider_app/CustomWidgets/progressDialog.dart';
import 'package:rider_app/DataHandler/appData.dart';
import 'package:rider_app/Models/address.model.dart';
import 'package:rider_app/Models/place.predictions.dart';

import '../config.maps.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController pickUpController = TextEditingController();
  TextEditingController dropOffController = TextEditingController();
  List<PlacePredictions> placePredictionsList = [];

  @override
  Widget build(BuildContext context) {
    String placeAdress =
        Provider.of<AppData>(context).pickUpLocation.placeName ?? "";
    pickUpController.text = placeAdress;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Container(
            height: 215,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 6,
                  spreadRadius: 0.5,
                  offset: Offset(0.7, 0.7),
                ),
              ],
            ),
            child: Padding(
              padding:
                  EdgeInsets.only(left: 25, top: 25, right: 25, bottom: 20),
              child: Column(
                children: [
                  SizedBox(height: 5),
                  Stack(
                    children: [
                      GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.arrow_back)),
                      Center(
                        child: Text("Entrer l'adresse de départ",
                            style: TextStyle(
                                fontSize: 18, fontFamily: "Brand-Bold")),
                      )
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Image.asset("assets/images/pickicon.png",
                          height: 16, width: 16),
                      SizedBox(width: 18),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(3),
                            child: TextField(
                              controller: pickUpController,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                  hintText: "Addresse de départ",
                                  fillColor: Colors.grey[400],
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(
                                      left: 11, top: 8, bottom: 8)),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Image.asset("assets/images/desticon.png",
                          height: 16, width: 16),
                      SizedBox(width: 18),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(3),
                            child: TextField(
                              onChanged: (val) {
                                findPlace(val);
                              },
                              controller: dropOffController,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                  hintText: "Addresse d'arrivée",
                                  fillColor: Colors.grey[400],
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(
                                      left: 11, top: 8, bottom: 8)),
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          //tile for predictions
          SizedBox(height: 10),
          (placePredictionsList.length > 0)
          ? Padding(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            child: ListView.separated(
              padding: EdgeInsets.all(0),
              itemBuilder: (context, index) {
                return PredictionTile(placePredictions: placePredictionsList[index]);
              },
              separatorBuilder: (BuildContext context, int index) => DividerWidget(),
              itemCount: placePredictionsList.length,
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
            ),
          )
              : Container(),
        ],
      ),
    );
  }

  void findPlace(String placeName) async {
    if (placeName.length > 1) {
      String autoCompleteURL =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$mapKey&components=country:fr";
      var res = await RequestAssistant.getRequest(autoCompleteURL);

      if (res == "failed") {
        return;
      }
      if (res["status"] == "OK") {
        var predictions = res["predictions"];
        var placesList = (predictions as List)
            .map((e) => PlacePredictions.fromJson(e))
            .toList();
        setState(() {
          placePredictionsList = placesList;
        });
      }
    }
  }
}

class PredictionTile extends StatelessWidget {
  final PlacePredictions placePredictions;
  PredictionTile({Key key, this.placePredictions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        getPlaceAddressDetails(placePredictions.place_id, context);
      },
      child: Container(
        child: Column(
          children: [
            SizedBox(width: 10),
            Row(
              children: [
                Icon(Icons.add_location),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Text(placePredictions.main_text,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 16)),
                      SizedBox(height: 2),
                      Text(placePredictions.secondary_text,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                      SizedBox(height: 8),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
  void getPlaceAddressDetails(String placeId, context) async {
    showDialog(context: context, builder: (BuildContext context) => ProgressDialog(message: "Patientez s'il-vous-plaît..."));
    String placeDetailsUrl = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey";
    var res = await RequestAssistant.getRequest(placeDetailsUrl);
    Navigator.pop(context);
    if (res == "failed") {
      return;
    }
    if (res["status"] == "OK") {
      Address address = Address();
      address.placeName = res["result"]["name"];
      address.placeID = placeId;
      address.latitude  = res["result"]["geometry"]["location"]["lat"];
      address.longitude  = res["result"]["geometry"]["location"]["lng"];

      Provider.of<AppData>(context, listen: false).updateDropOffLocationAddress(address);
      print("This is Drop off Location :: ");
      print(address.placeName);
      Navigator.pop(context, "obtainDirection");
    }
  }
}
