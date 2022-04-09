import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:century5/config/my_api.dart';
import 'package:century5/config/my_colors.dart';
import 'package:century5/config/my_components.dart';
import 'package:century5/controllers/auth_controller.dart';
import 'package:century5/views/auth/signin_screen.dart';
import 'package:century5/views/change_password/change_signin_password.dart';
import 'package:century5/views/change_password/change_transaction_password.dart';
import 'package:century5/views/dashboard/dashboard_screen.dart';
import 'package:century5/views/profile/profile_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:http/http.dart' as http;
class MyDrawerWidget extends StatefulWidget {
  const MyDrawerWidget({Key? key}) : super(key: key);

  @override
  State<MyDrawerWidget> createState() => _MyDrawerWidgetState();
}

class _MyDrawerWidgetState extends State<MyDrawerWidget> {

  var controller = Get.put(AuthController());
  // String name = '';
  // String image = '';

  //for user info
  // Future fetchMemberCreateData() async {
  //   var url = Uri.parse(MyApi.getMemberCreateData);
  //   var response = await http.post(url, headers: {
  //     'Accept': 'application/json',
  //     HttpHeaders.authorizationHeader: 'Bearer ${controller.token}',
  //   });
  //
  //   setState(() {
  //     for(int i=0;i<json.decode(response.body)['data']['profiles'].length;i++){
  //       if(json.decode(response.body)['data']['profiles'][i]['id'].toString()==controller.myId.toString()){
  //         name =json.decode(response.body)['data']['profiles'][i]['name'].toString();
  //         image =json.decode(response.body)['data']['profiles'][i]['image'].toString();
  //       }
  //     }
  //   });
  // }

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
          //print(json.decode(response.body)['message']);
          Get.snackbar(
              json.decode(response.body)['message'], "something wrong");
        }
        break;
    }
  }

  @override
  void initState() {
    fetchGetProfileData();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return GlassmorphicContainer(
      width: MediaQuery.of(context).size.width/1.4,
      height: MediaQuery.of(context).size.height,
      borderRadius: 0,
      blur: 20,
      alignment: Alignment.bottomCenter,
      border: 2,
      linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            MyColors.primary.withOpacity(0.5),
            MyColors.primary.withOpacity(0.05),
          ],
          stops: const [
            0.1,
            1,
          ]),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFffffff).withOpacity(0.0),
          const Color((0xFFFFFFFF)).withOpacity(0.0),
        ],
      ),
      child: Drawer(
        backgroundColor: Colors.transparent,
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.only(top:35,bottom: 40,left: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: NetworkImage('${MyApi.proImageUrl}$proImage'),),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nameNew.length>20?"${nameNew.substring(0,20)}...":nameNew,
                          style: MyComponents.myTextStyle(
                              Get.textTheme.headline6,
                              color: Colors.white,
                              fontWeight: FontWeight.w500
                          ),
                        ),
                        Text(
                          "@${controller.username.toString()}",
                          style: MyComponents.myTextStyle(
                            Get.textTheme.subtitle1,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const Divider()
                  ],
                ),

                Column(
                    children: [
                      InkWell(
                          onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=> DashboardScreen())),
                          child: DrawerItems(Icons.home_outlined,"  Home")),
                      InkWell(
                          onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>const ProfileViewScreen())),
                          child: DrawerItems(Icons.person_outline,"  Profile")),
                      InkWell(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (_)=>const ChangeSignPasswordScreen()));
                          },
                          child: DrawerItems(Icons.password_outlined,"  Change Password")),
                      InkWell(
                          onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>const ChangeTransactionPasswordScreen())),
                          child: DrawerItems(MdiIcons.shieldKeyOutline,"  Transaction Password")),
                      // //for test image upload
                      // InkWell(
                      //     onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>const TextScreen())),
                      //     child: DrawerItems(MdiIcons.shieldKeyOutline,"  Test")),
                      // DrawerItems(MdiIcons.shareVariantOutline,"  Share"),
                      // DrawerItems(MdiIcons.starOutline,"  Rate Us"),
                      // DrawerItems(MdiIcons.handshakeOutline,"  Contact Us"),
                    ]
                ),

                Row(
                  children: [
                    const Icon(FontAwesomeIcons.signOutAlt,color: Colors.white,),
                    // const SizedBox(width: 10,),
                    // const Text('Settings',style:TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                    // const SizedBox(width: 10,),
                    // Container(width: 2,height: 20,color: Colors.white,),
                    const SizedBox(width: 10,),
                    GestureDetector(
                      onTap: (){
                        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => SignInScreen()), (route) => false);
                      },
                      child: const Text('Log out',style:TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                    ),
                  ],
                )
              ],
            ),
          ),
      ),
    );
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
      padding: const EdgeInsets.only(bottom: 10),
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