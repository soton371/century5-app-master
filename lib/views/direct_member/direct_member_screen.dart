import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:century5/config/my_api.dart';
import 'package:century5/config/my_colors.dart';
import 'package:century5/config/my_components.dart';
import 'package:century5/controllers/auth_controller.dart';
import 'package:century5/views/direct_member/member_details.dart';
import 'package:century5/widgets/my_drawer_widget.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

class DirectMemberScreen extends StatefulWidget {
  const DirectMemberScreen({Key? key}) : super(key: key);

  @override
  _DirectMemberScreenState createState() => _DirectMemberScreenState();
}

class _DirectMemberScreenState extends State<DirectMemberScreen> {

  //
  var username,mobile,received,image,id;
  var memberList=[];

  //for token
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
    getDirectPersonList();
    fetchMemberCreateData();
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
      memberList = json.decode(response.body)['data']['members']['data'];
    });
  }

  //for test
  String name = '';

  //for user info
  Future fetchMemberCreateData() async {
    var url = Uri.parse(MyApi.getMemberCreateData);
    var response = await http.post(url, headers: {
      'Accept': 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer ${controller.token}',
    });

    setState(() {
      for(int i=0;i<json.decode(response.body)['data']['profiles'].length;i++){
        if(json.decode(response.body)['data']['profiles'][i]['id'].toString()==controller.myId.toString()){
          name =json.decode(response.body)['data']['profiles'][i]['name'].toString();
        }
      }
    });
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
        title: Text("Members",
          style: MyComponents.myTextStyle(
            Get.textTheme.headline6,
          ),
        ),
      ),
      drawer: const MyDrawerWidget(),
      body:memberList.isEmpty?const Center(child: Text('No members has taken place yet')): ListView.builder(
          padding: const EdgeInsets.all(5),
          physics: const BouncingScrollPhysics(),
          itemCount: memberList.length,
          itemBuilder: (_,index){
            username = memberList[index]['profile']['name'];
            mobile   = memberList[index]['profile']['mobile'];
            received = memberList[index]['is_received'];
            id       = memberList[index]['id'];
            return InkWell(
              onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>MemberDetailsScreen(index: index,))),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)
                ),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [

                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: const Image(
                          image: AssetImage('assets/images/level1.png'),
                          // image: NetworkImage(MyApi.levelImageUrl),
                          height: 45,
                          width: 45,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("   $username",
                            style: MyComponents.myTextStyle(
                                Get.textTheme.titleMedium,
                                fontWeight: FontWeight.w500
                            ),
                          ),
                          Text("   $mobile",
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
              ),
            );
          }
      ),
    ):noInternetConnection();
  }
}

class DrawerItems extends StatelessWidget {
  //DrawerItems({Key? key}) : super(key: key);
  IconData myIcon;
  String myString;


  DrawerItems(this.myIcon, this.myString);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        children: [
          Icon(myIcon,color: Colors.white,size: 30,),
          Text(myString,
            style: MyComponents.myTextStyle(
                Get.textTheme.titleMedium,
                color: Colors.white,
                fontWeight: FontWeight.w500
            ),
          )
        ],
      ),
    );
  }
}