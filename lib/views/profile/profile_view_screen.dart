import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:century5/config/my_api.dart';
import 'package:century5/config/my_colors.dart';
import 'package:century5/config/my_components.dart';
import 'package:century5/controllers/auth_controller.dart';
import 'package:century5/widgets/profile_info_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

class ProfileViewScreen extends StatefulWidget {
  const ProfileViewScreen({Key? key}) : super(key: key);

  @override
  _ProfileViewScreenState createState() => _ProfileViewScreenState();
}

class _ProfileViewScreenState extends State<ProfileViewScreen> {

  //for fetch profile info
  String name= '';
  String proImage= '';
  String memberSince= '';
  String username= '';
  String email= '';
  String mobile= '';
  String country= '';
  String age= '';
  String totalMember= '';

  var controller = Get.put(AuthController());

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
            name = json.decode(response.body)['data']['name'];
            proImage = json.decode(response.body)['data']['image'];
            memberSince = json.decode(response.body)['data']['created_at'];
            username = json.decode(response.body)['data']['members'][0]['username'];
            email = json.decode(response.body)['data']['email'];
            mobile = json.decode(response.body)['data']['mobile'];
            country = json.decode(response.body)['data']['country'];
            age = json.decode(response.body)['data']['age'];
            totalMember = json.decode(response.body)['data']['members'][0]['total_member'].toString();
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

  //for edit profile
  bool selectEdit = false;
  File? image;
  bool imageNull = true;

//for pick image
  Future pickImage() async{
    try{
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if(image == null) return;
      final imageTemp = File(image.path);
      setState(() {
        this.image = imageTemp;
      });
    }on PlatformException catch (e){
      print('error for image pick: $e');
    }
  }


  //upload image
  Future getUploadImg(File imageFile) async {

    var url = Uri.parse(MyApi.updateProfileData);
    Map<String, String> headers = {HttpHeaders.authorizationHeader: 'Bearer ${controller.token}',};


    final request = http.MultipartRequest('POST', url)..fields['profile_id']=controller.myId.toString()..headers.addAll(headers)
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    //for test
    try{
      var response = await request.send();
      if (response.statusCode == 200) {
        Get.snackbar('Success', 'image uploaded');
        print("image uploaded");
      }else{
        Get.snackbar('Failed', 'Please check in web');
        print("uploaded failed");
      }
    }catch(e){
      Get.snackbar('Exception', e.toString());
      print('my exception: $e');
    }

    // var response = await request.send();

    // if (response.statusCode == 200) {
    //   Get.snackbar('Success', 'image uploaded');
    //   print("image uploaded");
    // }else{
    //   Get.snackbar('Failed', 'Please check in web');
    //   print("uploaded failed");
    // }


  }

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
    // TODO: implement initState
    super.initState();
    checkRealtimeConnection();
    fetchGetProfileData();
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return status ? Scaffold(
      body:name==''?Center(child: Lottie.asset('assets/images/loading.json'),): Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height/2.2,
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
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30))
            ),
            child: Column(
              children: [
                //for appbar
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    children: [
                      InkWell(
                          onTap: ()=>Navigator.pop(context),
                          child: const Icon(Icons.arrow_back_outlined, color: Colors.white,)
                      ),
                      Text("  Profile",
                      style: MyComponents.myTextStyle(
                        Get.textTheme.headline6,
                        color: Colors.white,
                        fontWeight: FontWeight.w500
                      ),
                      ),
                      const Spacer(),
                      InkWell(
                          onTap: () async {
                            setState(() {
                              selectEdit = !selectEdit;
                              imageNull = false;
                            });

                            getUploadImg(image!);
                          },
                          child: selectEdit?const Icon(Icons.done, color: Colors.white,): const Icon(FontAwesomeIcons.userEdit, color: Colors.white,size: 22,))
                    ],
                  ),
                ),
                //for image
                proImage == null && image == null&& imageNull?Container(
                  margin:
                  const EdgeInsets.only(top: 20),
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: Colors.white70, width: 2),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/user.jpg')
                    )
                  ),
                ):
                Container(
                  margin:
                  const EdgeInsets.only(top: 20),
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: Colors.white70, width: 2),
                    image: image != null? DecorationImage(image: FileImage(image!,),opacity: selectEdit? 0.5:1.0,fit: BoxFit.cover):DecorationImage(image: NetworkImage('${MyApi.proImageUrl}$proImage'),opacity: selectEdit? 0.5:1.0,fit: BoxFit.cover),
                  ),
                  child: selectEdit?InkWell(
                    onTap: (){
                      pickImage();
                    },
                      child: const Icon(FontAwesomeIcons.camera, color: Colors.white,)):const Text(''),
                ),





                //for name
                Text(name,
                style: MyComponents.myTextStyle(
                  Get.textTheme.headlineSmall,
                  color: Colors.white,
                  fontWeight: FontWeight.w500
                )
                ),
                //for balance
                // Text("Member Since Feb 22",
                //     style: MyComponents.myTextStyle(
                //         Get.textTheme.titleMedium,
                //         color: Colors.white,
                //     )
                // ),
              ],
            ),
          ),
          //for info section
          Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(left: 15,right: 15,top: 20,bottom: 15),
                children: [
                  ProfileInfoListWidget(FontAwesomeIcons.user, "Username", username),
                  const SizedBox(height: 15,),
                  ProfileInfoListWidget(FontAwesomeIcons.envelope, "Email", email),
                  const SizedBox(height: 15,),
                  ProfileInfoListWidget(FontAwesomeIcons.mobileAlt, "Mobile", mobile),
                  const SizedBox(height: 15,),
                  ProfileInfoListWidget(FontAwesomeIcons.mapMarkerAlt, "Country", country),
                  const SizedBox(height: 15,),
                  ProfileInfoListWidget(FontAwesomeIcons.seedling, "Age", age),
                  const SizedBox(height: 15,),
                  ProfileInfoListWidget(FontAwesomeIcons.users, "Members", totalMember),
                ],
              )
          )
        ],
      ),
    ):noInternetConnection();
  }
}

