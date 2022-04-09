import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:century5/config/my_api.dart';
import 'package:century5/config/my_colors.dart';
import 'package:century5/config/my_components.dart';
import 'package:century5/controllers/auth_controller.dart';
import 'package:century5/widgets/my_drawer_widget.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

class LevelUserScreen extends StatefulWidget {
  const LevelUserScreen({Key? key}) : super(key: key);

  @override
  _LevelUserScreenState createState() => _LevelUserScreenState();
}

class _LevelUserScreenState extends State<LevelUserScreen> {
  double xOffset = 0;
  double yOffset = 0;
  double scaleFactor = 1;
  bool isDrawerOpen = false;

  String level='1';
  var userList;

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
    getMembersByLevel();
    // TODO: implement initState
    super.initState();
  }

  Future getMembersByLevel() async{
    var url = Uri.parse(MyApi.getMembersByLevel);
    var response = await http.post(url, body: {
      'level': level,
    }, headers: {
      "Accept": "application/json",
      HttpHeaders.authorizationHeader: 'Bearer ${controller.token}',
    });

    switch (json.decode(response.body)['status']) {
      case 1:
        {
          setState(() {
            userList = json.decode(response.body)['data']['members']['data'];
          });
        }
        break;
      default:
        {
          //print(json.decode(response.body)['message']);
          Get.snackbar(
              json.decode(response.body)['message'], "Something wrong", colorText: Colors.red);
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
        title: Text("User Level $level",
          style: MyComponents.myTextStyle(
            Get.textTheme.headline6,
          ),
        ),
      ),
      drawer: const MyDrawerWidget(),
      body:userList==null?Center(child: Lottie.asset('assets/images/loading.json'),): Column(
        children: [
          Container(
            margin: const EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: MyColors.background,
                borderRadius:
                const BorderRadius.all(Radius.circular(15)),
                boxShadow: [
                  BoxShadow(
                      blurRadius: 8.0,
                      color: MyColors.shadowColor.withAlpha(25),
                      offset: const Offset(0, 3)),
                ]),
            child: DropdownSearch<String>(
              dropdownSearchBaseStyle: MyComponents.myTextStyle(
                  Get.textTheme.bodyText1,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2),
              popupShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              mode: Mode.MENU,
              showSearchBox: true,
              showAsSuffixIcons: true,
              dropdownSearchDecoration: InputDecoration(
                hintStyle: MyComponents.myTextStyle(
                    Get.textTheme.bodyText1,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                    color: MyColors.blackColor.withAlpha(100)),
                //hintText: "Level 1",
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.all(15),
              ),
              items: const [
                'Level 1',
                'Level 2',
                'Level 3',
                'Level 4',
                'Level 5',
                'Level 6',
              ],
              onChanged: (v){
                var change = v!;
                setState(() {
                  level = change.split("Level ")[1];
                });
                getMembersByLevel();
              },
              selectedItem: "Level 1",
            ),
          ),
          Expanded(
            child: userList.length == 0?const Center(child: Text('No records found!')): ListView.builder(
                padding: const EdgeInsets.all(5),
                physics: const BouncingScrollPhysics(),
                itemCount: userList.length,
                itemBuilder: (_, index) {
                  String name = userList[index]['profile']['name'];
                  String mobile = userList[index]['profile']['mobile']??'';
                  var received = userList[index]['is_received'];
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                    child: Container(
                      padding: const EdgeInsets.all(10),
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
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                "   $name",
                                style: MyComponents.myTextStyle(
                                    Get.textTheme.titleMedium,
                                    fontWeight: FontWeight.w500),
                              ),
                              Text(
                                "   $mobile",
                                style: MyComponents.myTextStyle(
                                  Get.textTheme.caption,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          //for status
                          Icon(received==1?FontAwesomeIcons.solidCheckCircle:FontAwesomeIcons.infoCircle,color: received==1?MyColors.secondary:MyColors.rattingColor,)
                        ],
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
    ):noInternetConnection();
  }
}
