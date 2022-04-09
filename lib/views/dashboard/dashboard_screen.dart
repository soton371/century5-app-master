import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:century5/config/my_api.dart';
import 'package:century5/config/my_colors.dart';
import 'package:century5/config/my_components.dart';
import 'package:century5/controllers/auth_controller.dart';
import 'package:century5/views/direct_member/direct_member_screen.dart';
import 'package:century5/views/history/history_screen.dart';
import 'package:century5/views/level_user/level_user_screen.dart';
import 'package:century5/views/mybalance_transfer/my_balance_transfer_list.dart';
import 'package:century5/views/profile/profile_view_screen.dart';
import 'package:century5/views/user/existing_add_member_screen.dart';
import 'package:century5/views/user/new_add_member_screen.dart';
import 'package:century5/widgets/my_drawer_widget.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  //const DashboardScreen({Key? key}) : super(key: key);
  var controller = Get.put(AuthController());
  String availableBalance = '';
  String name = '';
  String image = '';
  List history = [];
  List receiverList = [];

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

  @override
  void initState() {
    fetchMemberCreateData();
    fetchFundTransferList();
    fetchFundTransferCreateData();
    fetchGetProfileData();
    checkRealtimeConnection();
    // TODO: implement initState
    super.initState();
  }

  //for profile data
  String proImage= '';
  String nameNew= '';

  Future fetchGetProfileData() async {
    var url = Uri.parse(MyApi.getProfileData);
    var response = await http.post(url, headers: {
      "Accept": "application/json",
      HttpHeaders.authorizationHeader: 'Bearer ${controller.token}',
    });

    switch (json.decode(response.body)['status']) {
      case 1:
        {
          setState(() {
            nameNew = json.decode(response.body)['data']['name'];
            proImage = json.decode(response.body)['data']['image'];

          });
        }
        break;
      default:
        {
          print(json.decode(response.body)['message']);
          // Get.snackbar(
          //     json.decode(response.body)['message'], "something wrong", colorText: Colors.blue);
        }
        break;
    }
  }

  //for user info
  Future fetchMemberCreateData() async {
    var url = Uri.parse(MyApi.getMemberCreateData);
    var response = await http.post(url, headers: {
      'Accept': 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer ${controller.token}',
    });

    setState(() {
      availableBalance =
          json.decode(response.body)['data']['availableBalance'].toString();
      for(int i=0;i<json.decode(response.body)['data']['profiles'].length;i++){
        if(json.decode(response.body)['data']['profiles'][i]['id'].toString()==controller.myId.toString()){
          name =json.decode(response.body)['data']['profiles'][i]['name'].toString();
          //for user image
          image = json.decode(response.body)['data']['profiles'][i]['image'].toString();
        }
      }
    });
  }

  //for transaction list
  Future fetchFundTransferList() async {
    var url = Uri.parse(MyApi.getFundTransferList);
    var response = await http.post(url, headers: {
      "Accept": "application/json",
      HttpHeaders.authorizationHeader: 'Bearer ${controller.token}',
    });

    switch (json.decode(response.body)['status']) {
      case 1:
        {
          setState(() {
            history = json.decode(response.body)['data']['data'];
          });
        }
        break;
      default:
        {
          print(json.decode(response.body)['message']);
          // Get.snackbar(
          //     json.decode(response.body)['message'], "something wrong");
        }
        break;
    }
  }

  //for receiver lis
  //for fund transfer
  Future fetchFundTransferCreateData() async {
    var url = Uri.parse(MyApi.getFundTransferCreateData);
    var response = await http.post(url, headers: {
      "Accept": "application/json",
      HttpHeaders.authorizationHeader: 'Bearer ${controller.token}',
    });

    switch (json.decode(response.body)['status']) {
      case 1:
        {
          setState(() {
            receiverList = json.decode(response.body)['data']['users'];
            availableBalance =
            json.decode(response.body)['data']['availableBalance'].toString();
          });
        }
        break;
      default:
        {
          print(json.decode(response.body)['message']);
          // Get.snackbar(
          //     json.decode(response.body)['message'], "something wrong");
        }
        break;
    }
  }


  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  Widget noInternetConnection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset('assets/images/90478-disconnect.json', height: 150),
        SizedBox(height: 20,),
        Text('No Internet Connection',
        style: MyComponents.myTextStyle(
          Get.textTheme.titleMedium,
        ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return status? availableBalance==''?Center(child: Lottie.asset('assets/images/loading.json'),): Scaffold(
        body: Container(
      height: Get.height,
      width: Get.width,
      //color: Colors.red,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            MyColors.primary,
            MyColors.primary.withOpacity(0.8),
            MyColors.primary.withOpacity(0.6),
            MyColors.primary.withOpacity(0.4),
          ],
        ),
      ),
      child: Column(
        children: [
          Padding(
            //padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            padding: const EdgeInsets.only(left: 15,top: 20,bottom: 20),
            child: Row(
              children: [
                InkWell(
                  onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>const ProfileViewScreen())),
                  child:proImage != null ? CircleAvatar(
                    backgroundImage: NetworkImage('${MyApi.proImageUrl}$proImage'),
                    //backgroundImage: AssetImage("assets/images/user.jpg"),
                    radius: 25,
                  ):const CircleAvatar(
                    backgroundImage: AssetImage("assets/images/user.jpg"),
                    radius: 25,
                  )
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "   @${controller.username.toString()}",
                      style: MyComponents.myTextStyle(
                        Get.textTheme.subtitle1,
                        color: MyColors.onPrimary,
                      ),
                    ),
                    Text( nameNew.length>22?"  ${nameNew.substring(0,22)}..":
                      "  $nameNew",
                      style: MyComponents.myTextStyle(Get.textTheme.headline6,
                          color: Colors.white, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                    onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>const MyDrawerWidget())),
                    icon: const Icon(Icons.more_vert_outlined, color: Colors.white,)
                )
              ],
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          //balance section
          Text(
            "Balance",
            style: MyComponents.myTextStyle(Get.textTheme.titleMedium,
                color: MyColors.textWhite),
          ),
          //SizedBox(height: 5,),
          Text(
            "৳$availableBalance",
            style: MyComponents.myTextStyle(
              Get.textTheme.headline4,
              color: MyColors.textWhite,
              fontWeight: FontWeight.w600,
              //letterSpacing: 1.5
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          //button section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  GestureDetector(
                    onTap: () => Get.defaultDialog(
                        backgroundColor: Colors.white54,
                        titleStyle: MyComponents.myTextStyle(
                            Get.textTheme.headlineSmall,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                        title: "Add Member",
                        content: Row(
                          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context,
                                      rootNavigator: true)
                                      .pop();
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const ExistingAddMemberScreen()));
                                },
                                child: Text("Existing Member",
                                    style: MyComponents.myTextStyle(
                                      Get.textTheme.button,
                                      color: Colors.white,
                                    )),
                                style: ElevatedButton.styleFrom(
                                    primary: MyColors.rattingColor,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10))),
                              ),
                            ),
                            const SizedBox(width: 10,),
                            //for new add member
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context,
                                      rootNavigator: true)
                                      .pop();
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const NewAddMemberScreen()));
                                },
                                child: Text("New Member",
                                    style: MyComponents.myTextStyle(
                                      Get.textTheme.button,
                                      color: Colors.white,
                                    )),
                                style: ElevatedButton.styleFrom(
                                    primary: MyColors.primary,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10))),
                              ),
                            ),
                          ],
                        )),
                    child: Container(
                      height: 55,
                      width: 55,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.54),
                          borderRadius: BorderRadius.circular(18)),
                      child: const FaIcon(
                        FontAwesomeIcons.userPlus,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    "Add",
                    style: MyComponents.myTextStyle(Get.textTheme.subtitle2,
                        //fontWeight: FontWeight.w500,
                        color: MyColors.textWhite),
                  )
                ],
              ),
              Column(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const DirectMemberScreen())),
                    child: Container(
                      alignment: Alignment.center,
                      height: 55,
                      width: 55,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.54),
                          borderRadius: BorderRadius.circular(18)),
                      child: const FaIcon(
                        FontAwesomeIcons.users,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    "Members",
                    style: MyComponents.myTextStyle(Get.textTheme.subtitle2,
                        //fontWeight: FontWeight.w500,
                        color: MyColors.textWhite),
                  )
                ],
              ),
              //for level
              Column(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const LevelUserScreen())),
                    child: Container(
                      height: 55,
                      width: 55,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.54),
                          borderRadius: BorderRadius.circular(18)),
                      child: const FaIcon(
                        FontAwesomeIcons.signal,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    "Level",
                    style: MyComponents.myTextStyle(Get.textTheme.subtitle2,
                        //fontWeight: FontWeight.w500,
                        color: MyColors.textWhite),
                  )
                ],
              ),
              Column(
                children: [
                  GestureDetector(
                    onTap: () => Get.defaultDialog(
                      titlePadding: const EdgeInsets.only(top: 0),
                      contentPadding: const EdgeInsets.only(top: 0),
                        backgroundColor: Colors.white54,
                        titleStyle: MyComponents.myTextStyle(
                            Get.textTheme.headlineSmall,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                        title: "",
                        content: Column(
                          children: [
                            Row(
                              children: [
                                //for history
                                Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop();
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    const HistoryScreen()));
                                      },
                                      child: Container(
                                        height: 55,
                                        width: 55,
                                        margin: const EdgeInsets.only(left: 15),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topRight,
                                              end: Alignment.bottomLeft,
                                              colors: [
                                                MyColors.primary,
                                                MyColors.primary
                                                    .withOpacity(0.8),
                                                MyColors.primary
                                                    .withOpacity(0.6),
                                                MyColors.primary
                                                    .withOpacity(0.4),
                                              ],
                                            ),
                                            color:
                                                Colors.white.withOpacity(0.54),
                                            borderRadius:
                                                BorderRadius.circular(18)),
                                        child: const FaIcon(
                                          FontAwesomeIcons.history,
                                          color: Colors.white,
                                          size: 25,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "History",
                                      style: MyComponents.myTextStyle(
                                          Get.textTheme.subtitle2,
                                          //fontWeight: FontWeight.w500,
                                          color: MyColors.textWhite),
                                    )
                                  ],
                                ),
                                const SizedBox(width: 15,),
                                //for my balance
                                Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context,
                                            rootNavigator: true)
                                            .pop();
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    const MyBalanceTransferListScreen()));
                                      },
                                      child: Container(
                                        height: 55,
                                        width: 55,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topRight,
                                              end: Alignment.bottomLeft,
                                              colors: [
                                                MyColors.primary,
                                                MyColors.primary
                                                    .withOpacity(0.8),
                                                MyColors.primary
                                                    .withOpacity(0.6),
                                                MyColors.primary
                                                    .withOpacity(0.4),
                                              ],
                                            ),
                                            color:
                                            Colors.white.withOpacity(0.54),
                                            borderRadius:
                                            BorderRadius.circular(18)),
                                        child: const FaIcon(
                                          FontAwesomeIcons.coins,
                                          color: Colors.white,
                                          size: 25,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "Balance",
                                      style: MyComponents.myTextStyle(
                                          Get.textTheme.subtitle2,
                                          //fontWeight: FontWeight.w500,
                                          color: MyColors.textWhite),
                                    )
                                  ],
                                ),
                              ],
                            )
                          ],
                        )),
                    child: Container(
                      height: 55,
                      width: 55,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.54),
                          borderRadius: BorderRadius.circular(18)),
                      child: const FaIcon(
                        FontAwesomeIcons.buromobelexperte,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    "More",
                    style: MyComponents.myTextStyle(Get.textTheme.subtitle2,
                        //fontWeight: FontWeight.w500,
                        color: MyColors.textWhite),
                  )
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 30,
          ),
          // Last transaction
          Expanded(
            child: Container(
              width: Get.width,
              padding: const EdgeInsets.only(top: 20, left: 15, right: 15),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(25))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Last Transaction",
                    style: MyComponents.myTextStyle(Get.textTheme.headline6,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Flexible(
                    child:history.length==0?const Center(child: const Text('No transaction has taken place yet')): ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: history.length >= 10 ? 10 : history.length,
                        itemBuilder: (_,index){
                          String date = history[index]['date'];
                         String amount = history[index]['amount'];
                         var approved = history[index]['is_approved'];
                         String receiverName='admin@gmail.com';
                          //for name
                          var receiverId = history[index]['receiver_id'];
                          for(int i = 0;i<receiverList.length;i++){
                            var findId = receiverList[i]['id'];
                            if(receiverId==findId){
                              receiverName = receiverList[i]['username'];

                            }
                          }
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 15),
                              height: 40,
                              width: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: receiverId.toString() == controller.myId.toString() ? MyColors.secondaryVariant.withOpacity(0.15): Colors.red.withOpacity(0.15)),
                              child: receiverId.toString() == controller.myId.toString() ? RotatedBox(quarterTurns:2,child: Icon(FontAwesomeIcons.share,color: MyColors.secondaryVariant,)) : const Icon(FontAwesomeIcons.share,color: Colors.red,),

                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "  $receiverName",
                                  style: MyComponents.myTextStyle(
                                      Get.textTheme.titleMedium,
                                  ),
                                ),
                                Text(
                                  "   $date",
                                  style: MyComponents.myTextStyle(
                                    Get.textTheme.caption,
                                  ),
                                )
                              ],
                            ),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                receiverId.toString() == controller.myId.toString() ?
                                Text(
                                  "+$amount",
                                  style: MyComponents.myTextStyle(
                                      Get.textTheme.titleMedium,
                                      //fontWeight: FontWeight.w500,
                                      color: MyColors.secondaryVariant
                                  ),
                                ):Text(
                                  "-$amount",
                                  style: MyComponents.myTextStyle(
                                      Get.textTheme.titleMedium,
                                      //fontWeight: FontWeight.w500,
                                      color: Colors.red
                                  ),
                                ),

                                Text(
                          approved == 1 ? "Approved" : 'Pending',
                                  style: MyComponents.myTextStyle(
                                    Get.textTheme.caption,
                                  ),
                                )
                              ],
                            ),
                          ],
                        );
                        }
                    ),
                  ),

                ],
              ),
            ),
          )
        ],
      ),
    )):noInternetConnection();
  }
}

