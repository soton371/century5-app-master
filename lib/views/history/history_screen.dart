import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:century5/config/my_api.dart';
import 'package:century5/config/my_colors.dart';
import 'package:century5/config/my_components.dart';
import 'package:century5/config/my_sizes.dart';
import 'package:century5/controllers/auth_controller.dart';
import 'package:century5/widgets/my_drawer_widget.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  double xOffset = 0;
  double yOffset = 0;
  double scaleFactor = 1;
  bool isDrawerOpen = false;

  var controller = Get.put(AuthController());

  //for check realtime internet
  bool status = true;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription _streamSubscription;

  void checkRealtimeConnection() {
    _streamSubscription = _connectivity.onConnectivityChanged.listen((event) {
      if (event == ConnectivityResult.mobile) {
        status = true;
      } else if (event == ConnectivityResult.wifi) {
        setState(() {
          status = true;
        });

      } else {
        status = false;
      }
      setState(() {});
    });
  }

  Widget noInternetConnection() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/images/90478-disconnect.json', height: 150),
            const SizedBox(height: 20,),
            Text('No Internet Connection',
              style: MyComponents.myTextStyle(
                Get.textTheme.titleMedium,
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    checkRealtimeConnection();
    fetchMemberLevelHistories();
    // TODO: implement initState
    super.initState();
  }

  var name,date,image;

  List history = [];

  Future fetchMemberLevelHistories() async{
    var url = Uri.parse(MyApi.getMemberLevelHistories);
    var response = await http.post(url, headers: {
      "Accept": "application/json",
      HttpHeaders.authorizationHeader: 'Bearer ${controller.token}',
    });

    switch (json.decode(response.body)['status']) {
      case 1:
        {
          setState(() {
            history = json.decode(response.body)['data']['histories'];
          });
        }
        break;
      default:
        {
          //print(json.decode(response.body)['message']);
          Get.snackbar(
              json.decode(response.body)['message'], "something wrong",colorText: Colors.red);
        }
        break;
    }
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return status? Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.fullAABackground,
        elevation: 0,
        titleSpacing: 0,
        title: Text("History",
          style: MyComponents.myTextStyle(
            Get.textTheme.headline6,
          ),
        ),
      ),
      drawer: const MyDrawerWidget(),
      body: history.isEmpty?const Center(child: Text('No history has taken place yet'),): ListView.builder(
          itemCount: history.length,
          itemBuilder: (_,index){
            name = history[index]['level']['name'];
            date = history[index]['date'];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 15),
              margin: EdgeInsets.only(top: MySizes.size15, left: MySizes.size15,right: MySizes.size15),
              decoration: BoxDecoration(
                color: MyColors.background,
                borderRadius: BorderRadius.all(Radius.circular(MySizes.size15)),
                boxShadow: [
                  BoxShadow(
                    color: MyColors.shadowColor.withAlpha(26),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image(
                      image: NetworkImage(MyApi.levelImageUrl),
                      height: 45,
                      width: 45,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("   $name",
                        style: MyComponents.myTextStyle(
                            Get.textTheme.titleMedium,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                      Text("   $date",
                        style: MyComponents.myTextStyle(
                          Get.textTheme.caption,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
      ),
    ):noInternetConnection();
  }
}
