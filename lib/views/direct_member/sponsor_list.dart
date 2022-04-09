import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:century5/config/my_api.dart';
import 'package:century5/config/my_colors.dart';
import 'package:century5/config/my_components.dart';
import 'package:century5/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class SponsorListScreen extends StatefulWidget {
  const SponsorListScreen({Key? key}) : super(key: key);

  @override
  _SponsorListScreenState createState() => _SponsorListScreenState();
}

class _SponsorListScreenState extends State<SponsorListScreen> {

  var username,mobile,received,image;
  var memberList=[];
//for token
  var controller = Get.put(AuthController());

  @override
  void initState() {
    getMemberCreateData();
    // TODO: implement initState
    super.initState();
  }

  Future getMemberCreateData() async {
    var url = Uri.parse(MyApi.getMemberCreateData);
    var response = await http.post(url, headers: {
      'Accept': 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer ${controller.token}',
    });
    setState(() {
      // sponsor = json.decode(response.body)['data']['sponsors'][widget.index]['members'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: (){},

              ),
              Text("Members ",
                style: MyComponents.myTextStyle(
                  Get.textTheme.headline6,
                ),
              )
            ],
          ),
          Expanded(
            child: ListView.builder(
                padding: const EdgeInsets.all(5),
                physics: const BouncingScrollPhysics(),
                itemCount: memberList.length,
                itemBuilder: (_,index){
                  username = memberList[index]['profile']['name'];
                  mobile = memberList[index]['profile']['mobile'];
                  received = memberList[index]['is_received'];
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)
                    ),
                    elevation: 0,
                    child: GestureDetector(
                      onTap: (){
                        //Navigator.push(context, MaterialPageRoute(builder: (_)=>MemberDetailsScreen(index: index)));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Image(image: AssetImage(index%2==0?'assets/images/level1.png':'assets/images/level2.png'),height: 45,width: 45,),
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
          ),
        ],
      ),
    );
  }
}
