import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:century5/config/my_api.dart';
import 'package:century5/config/my_colors.dart';
import 'package:century5/config/my_components.dart';
import 'package:century5/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class MemberDetailsScreen extends StatefulWidget {
  //const MemberDetailsScreen({Key? key}) : super(key: key);
  var index;
  MemberDetailsScreen({this.index});

  @override
  _MemberDetailsScreenState createState() => _MemberDetailsScreenState();
}

class _MemberDetailsScreenState extends State<MemberDetailsScreen> {

  var name,username,mobile,email,age,country,totalMember,rank,status;
  List memberList=[];
  List sponsor=[];
  var myIndex;

  //for token
  var controller = Get.put(AuthController());

  //for check realtime internet
  bool internetStatus = true;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription _streamSubscription;

  void checkRealtimeConnection() {
    _streamSubscription = _connectivity.onConnectivityChanged.listen((event) {
      if (event == ConnectivityResult.mobile) {
        internetStatus = true;
      } else if (event == ConnectivityResult.wifi) {
        setState(() {
          internetStatus = true;
        });

      } else {
        internetStatus = false;
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
    getDirectPersonList();
    getMemberCreateData();
    //fetchDirectPersonList();
    // TODO: implement initState
    super.initState();
  }


  Future getDirectPersonList() async {
    var url = Uri.parse(MyApi.getDirectPersonList);
    var response = await http.post(url, headers: {
      'Accept': 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer ${controller.token}',
    });
    setState(() {
      memberList  = json.decode(response.body)['data']['members']['data'];
      name        = memberList[widget.index]['profile']['name'];
      email       = memberList[widget.index]['profile']['email'] ?? '';
      mobile      = memberList[widget.index]['profile']['mobile'] ?? '';
      country     = memberList[widget.index]['profile']['country'] ?? '';
      age         = memberList[widget.index]['profile']['age'] ?? '';
      username    = memberList[widget.index]['username'];
      status      = memberList[widget.index]['is_received'];
      totalMember = json.decode(response.body)['data']['memberWithTotal'][widget.index]['total_member_count'].toString();
      rank        = memberList[widget.index]['current_rank']==null?'': memberList[widget.index]['current_rank']['level']['name'];
    });
  }

  Future getMemberCreateData() async {
    var url = Uri.parse(MyApi.getMemberCreateData);
    var response = await http.post(url, headers: {
      'Accept': 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer ${controller.token}',
    });
    setState(() {
      sponsor = json.decode(response.body)['data']['sponsors'][widget.index]['members'];
    });
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return internetStatus? Scaffold(
      body: SafeArea(
          child:username==null? Center(child: Lottie.asset('assets/images/loading.json')): Column(
            children: [

              //for app bar
              Row(
                children: [IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: (){
                      Get.back();
                    },
                  ),
                  Text("User Details",
                    style: MyComponents.myTextStyle(
                      Get.textTheme.headline6,
                    ),
                  )
                ],
              ),
              //for list
              Expanded(
                  child:ListView(
                    padding: const EdgeInsets.all(15),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: MyComponents.myTextStyle(
                                  Get.textTheme.headlineSmall,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "@$username",
                                style: MyComponents.myTextStyle(
                                  Get.textTheme.subtitle2,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          // const CircleAvatar(
                          //   backgroundImage: AssetImage("assets/images/user.jpg"),
                          //   radius: 22,
                          // ),
                        ],
                      ),
                      //for sponsor list
                      GestureDetector(
                        onTap: (){

                          Get.defaultDialog(
                            title: "Sponsor",
                            content: Expanded(
                              child: ListView.builder(
                                  padding: const EdgeInsets.all(5),
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: sponsor.length,
                                  itemBuilder: (_,index){
                                    return Card(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15)
                                      ),
                                      elevation: 0,
                                      child: GestureDetector(
                                        onTap: (){
                                          Navigator.push(context, MaterialPageRoute(builder: (_)=>MemberDetailsScreen(index: index)));
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          child: Row(
                                            children: [
                                              // ClipRRect(
                                              //   borderRadius: BorderRadius.circular(5),
                                              //   child: Image(image: AssetImage("${index%2==0?'assets/images/level1.png':'assets/images/level2.png'}"),height: 45,width: 45,),
                                              // ),
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
                                                  Text("   ${sponsor[index]['username']}",
                                                    style: MyComponents.myTextStyle(
                                                        Get.textTheme.titleMedium,
                                                        fontWeight: FontWeight.w500
                                                    ),
                                                  ),
                                                  // Text("   ${sponsor[index]['mobile']}",
                                                  //   style: MyComponents.myTextStyle(
                                                  //     Get.textTheme.caption,
                                                  //   ),
                                                  // ),
                                                ],
                                              ),
                                              const Spacer(),
                                              //for status
                                              //Icon(received==1?FontAwesomeIcons.solidCheckCircle:FontAwesomeIcons.infoCircle,color: received==1?MyColors.secondary:MyColors.rattingColor,)
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                              ),
                            )
                          );
                          //Navigator.of(context, rootNavigator: true).pop();
                          //Navigator.push(context, MaterialPageRoute(builder: (_)=>SponsorListScreen()));
                        },
                        child: Container(
                          margin: const EdgeInsets.only(top: 20,bottom: 20),
                          padding: const EdgeInsets.all(10),
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
                            borderRadius: BorderRadius.circular(15)
                          ),
                          //height: 80,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Total Sponsor",
                                  style: MyComponents.myTextStyle(
                                    Get.textTheme.titleMedium,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500
                                  ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(FontAwesomeIcons.users,color: Colors.white,),
                                      Text("   ${sponsor.length.toString()}",
                                        style: MyComponents.myTextStyle(
                                            Get.textTheme.headline5,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                              const Icon(Icons.arrow_forward_ios_outlined,color: Colors.white,),
                            ],
                          ),
                        ),
                      ),
                      //for status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Status",
                            style: MyComponents.myTextStyle(
                                Get.textTheme.titleMedium,
                                color: Colors.black,
                                fontWeight: FontWeight.w500
                            ),
                          ),
                          Text(status==1?"Received":'Not Received',
                          style: MyComponents.myTextStyle(
                            Get.textTheme.titleSmall,
                            color:status==1? MyColors.secondary:MyColors.rattingColor,
                            fontWeight: FontWeight.w500
                          ),
                          ),
                        ],
                      ),
                      //for info
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 15),
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15)
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Email:",
                                  style: MyComponents.myTextStyle(
                                      Get.textTheme.titleSmall,
                                      fontWeight: FontWeight.w500
                                  ),
                                ),
                                Text(email,
                                  style: MyComponents.myTextStyle(
                                      Get.textTheme.titleSmall,
                                      fontWeight: FontWeight.w500
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Mobile:",
                                  style: MyComponents.myTextStyle(
                                      Get.textTheme.titleSmall,
                                      fontWeight: FontWeight.w500
                                  ),
                                ),
                                Text(mobile,
                                  style: MyComponents.myTextStyle(
                                      Get.textTheme.titleSmall,
                                      fontWeight: FontWeight.w500
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Country:",
                                style: MyComponents.myTextStyle(
                                  Get.textTheme.titleSmall,
                                  fontWeight: FontWeight.w500
                                ),
                                ),
                                Text(country,
                                  style: MyComponents.myTextStyle(
                                      Get.textTheme.titleSmall,
                                      fontWeight: FontWeight.w500
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Age:",
                                  style: MyComponents.myTextStyle(
                                      Get.textTheme.titleSmall,
                                      fontWeight: FontWeight.w500
                                  ),
                                ),
                                Text(age,
                                  style: MyComponents.myTextStyle(
                                      Get.textTheme.titleSmall,
                                      fontWeight: FontWeight.w500
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Total Member:",
                                  style: MyComponents.myTextStyle(
                                      Get.textTheme.titleSmall,
                                      fontWeight: FontWeight.w500
                                  ),
                                ),
                                Text(totalMember.toString(),
                                  style: MyComponents.myTextStyle(
                                      Get.textTheme.titleSmall,
                                      fontWeight: FontWeight.w500
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Rank:",
                                  style: MyComponents.myTextStyle(
                                      Get.textTheme.titleSmall,
                                      fontWeight: FontWeight.w500
                                  ),
                                ),
                                Text(rank,
                                  style: MyComponents.myTextStyle(
                                      Get.textTheme.titleSmall,
                                      fontWeight: FontWeight.w500
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  )
              )
            ],
          )
      ),
    ):noInternetConnection();
  }
}
