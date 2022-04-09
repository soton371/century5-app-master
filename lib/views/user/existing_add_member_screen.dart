import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:century5/config/my_api.dart';
import 'package:century5/config/my_colors.dart';
import 'package:century5/config/my_components.dart';
import 'package:century5/config/my_sizes.dart';
import 'package:century5/controllers/auth_controller.dart';
import 'package:century5/views/fund_transfer/fund_transfer_list.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ExistingAddMemberScreen extends StatefulWidget {
  const ExistingAddMemberScreen({Key? key}) : super(key: key);

  @override
  _ExistingAddMemberScreenState createState() => _ExistingAddMemberScreenState();
}

class _ExistingAddMemberScreenState extends State<ExistingAddMemberScreen> {
  final GlobalKey<FormState> newAddMemberKey = GlobalKey<FormState>();

  //for data received
  // var fullNameController = TextEditingController(),
  //     usernameController = TextEditingController(),
  //     mobileController = TextEditingController(),
  //     emailController = TextEditingController(),
  //     ageController = TextEditingController(),
  //     transactionPasswordController = TextEditingController(),
  //     confirmPasswordController = TextEditingController(),
  //     passwordController = TextEditingController();

  //for store value
  var currentUser,
      sponsors,
      selectSponsor,
  selectMember,
      productInfo,
      availableBalance,
      fullName,
      username,
      mobile,
      email,
      age,
      country,
      selectCountry,
      password,
      confirmPassword,
      transactionPassword,
      selectProduct,
      productIndex,
      productPrice="10",
      productId='1';
  var showPrice = 0;
  var show = 0;
  List memberInfoList = [];

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
    getMemberCreateData();
    fetchGetProfileData();
    //getProductPrice();
    //existingAddMember();
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  //for profile
  String proImage= '';
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

  Future getDirectPersonList() async {
    var url = Uri.parse(MyApi.getDirectPersonList);
    var response = await http.post(url, headers: {
      'Accept': 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer ${controller.token}',
    });
    setState(() {
      currentUser =
      json.decode(response.body)['data']['currentUser']['username'];
      sponsors = json.decode(response.body)['data']['currentUser']['members'];
    });
  }

  Future getMemberCreateData() async {
    var url = Uri.parse(MyApi.getMemberCreateData);
    var response = await http.post(url, headers: {
      'Accept': 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer ${controller.token}',
    });

    setState(() {
      productInfo = json.decode(response.body)['data']['products'];
      availableBalance =
          json.decode(response.body)['data']['availableBalance'].toString();
      memberInfoList = json.decode(response.body)['data']['profiles'];
    });
  }

  getProductPrice() {
    for (int i = 0; i < productInfo.length; i++) {
      if(productInfo[i]['name']==selectProduct.toString()){
        setState(() {
          productPrice = productInfo[i]['price'];
          print("my method product price: ${productPrice}");
        });
        return productPrice;
      }
    }
  }

  getFullName() {
    for (int i = 0; i < memberInfoList.length; i++) {
      if(memberInfoList[i]['name']==selectMember.toString()){
        setState(() {
          fullName = memberInfoList[i]['name'];
          print("my method product price: $fullName");
        });
        return fullName;
      }
    }
  }

  getMobile() {
    for (int i = 0; i < memberInfoList.length; i++) {
      if(memberInfoList[i]['name']==selectMember.toString()){
        setState(() {
          mobile = memberInfoList[i]['mobile'];
          print("my method product price: $mobile");
        });
        return mobile;
      }
    }
  }

  getEmail() {
    for (int i = 0; i < memberInfoList.length; i++) {
      if(memberInfoList[i]['name']==selectMember.toString()){
        setState(() {
          email = memberInfoList[i]['email'];
          print("my method product price: $email");
        });
        return email;
      }
    }
  }

  getAge() {
    for (int i = 0; i < memberInfoList.length; i++) {
      if(memberInfoList[i]['name']==selectMember.toString()){
        setState(() {
          age = memberInfoList[i]['age'];
          print("my method product price: $age");
        });
        return age;
      }
    }
  }

  getCountry() {
    for (int i = 0; i < memberInfoList.length; i++) {
      if(memberInfoList[i]['name']==selectMember.toString()){
        setState(() {
          country = memberInfoList[i]['country'];
          print("my method product price: $country");
        });
        return country;
      }
    }
  }

  getProductId() {
    for (int i = 0; i < productInfo.length; i++) {
      if(productInfo[i]['name']==selectProduct.toString()){
        setState(() {
          productId = productInfo[i]['id'].toString();
          print("my method product id: ${productId}");
        });
        return productId;
      }
    }
  }



  Future existingAddMember() async {
    newAddMemberKey.currentState!.save();
    var url = Uri.parse(MyApi.newAddMember);

    var response = await http.post(url, body: {

      "sponsor": selectSponsor?? '',
      "username": username?? '',
      "name": fullName?? '',
      "mobile": mobile?? '',
      "email": email?? '',
      "age": age?? '',
      "country": country?? '',
      'product_id': productId!= null ? productId : '0',
      "password": password?? '',
      "password_confirmation": confirmPassword?? '',
      "transaction_password": transactionPassword?? '',
      "product":selectProduct?? '',
      "price": productPrice!= null ? productPrice : '00.0',

    }, headers: {
      "Accept": "application/json",
      HttpHeaders.authorizationHeader: 'Bearer ${controller.token}',
    });

    switch (json.decode(response.body)['status']) {
      case 1:
        {
          print(json.decode(response.body)['message']);
          Get.snackbar(json.decode(response.body)['message'], 'Add existing member');
        }
        break;
      default:
        {
          print(json.decode(response.body)['message']);
          Get.snackbar(json.decode(response.body)['message'], json.decode(response.body)['data']);
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return status? Scaffold(
      body: productInfo==null? Center(child: Lottie.asset('assets/images/loading.json')):  Container(
        height: Get.height,
        width: Get.width,
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
              padding:
              const EdgeInsets.only(top: 40, left: 15, right: 15, bottom: 20),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage('${MyApi.proImageUrl}$proImage'),
                    radius: 22,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "  $currentUser",
                        style: MyComponents.myTextStyle(Get.textTheme.headline6,
                            color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "   ৳$availableBalance",
                        style: MyComponents.myTextStyle(
                          Get.textTheme.subtitle1,
                          color: MyColors.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            //for input
            Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    color: MyColors.fullAABackground,
                  ),
                  child:double.parse(availableBalance)<=0?Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('! Sorry,\n',
                          style: TextStyle(
                              color: MyColors.error,
                              fontSize: 20
                          ),
                        ),
                        Text('You do not have available balance to add any member, You can get the balance from admin or upper level of sponsor. Your Current Available Balance is : ৳$availableBalance',
                          style: TextStyle(
                              color: MyColors.error
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('To Send a Request for Balance Transfer:',
                              style: TextStyle(
                                  color: MyColors.error
                              ),
                            ),
                            TextButton(
                                onPressed: ()=>Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const FundTransferListScreen())),
                                child: const Text('Click Here')
                            )
                          ],
                        )
                      ],
                    ),
                  ): SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Form(
                      key: newAddMemberKey,
                      child: Column(
                        children: [
                          //for sponsor dropdown
                          Container(
                            margin: EdgeInsets.only(
                                left: MySizes.padding15,
                                right: MySizes.padding15,
                                top: 30),
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
                                hintText: '-Select Sponsor-',
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.all(15),
                              ),
                              items: [
                                for (int i = 0; i < sponsors.length; i++) ...{
                                  sponsors[i]['username'],
                                }
                              ],
                              onChanged: (v) => selectSponsor = v!,
                            ),
                          ),
                          //for full name dropdown
                          Container(
                            margin: EdgeInsets.only(
                                left: MySizes.padding15,
                                right: MySizes.padding15,
                                top: 30),
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
                                hintText: '-Select Member-',
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.all(15),
                              ),
                              items: [
                                for (int i = 0; i < sponsors.length; i++) ...{
                                  memberInfoList[i]['name'],
                                }
                              ],
                              onChanged: (v) {
                                selectMember = v!;
                                show =1;
                                getFullName();
                                getMobile();
                                getEmail();
                                getAge();
                                getCountry();
                              },
                            ),
                          ),
                          //for user full name
                          Container(
                            margin: EdgeInsets.only(
                                left: MySizes.padding15,
                                right: MySizes.padding15,
                                top: 30),
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
                            child: TextFormField(
                              obscureText: false,
                              enabled: false,
                              style: MyComponents.myTextStyle(
                                  Get.textTheme.bodyText1,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.2),
                              decoration: InputDecoration(
                                hintStyle: MyComponents.myTextStyle(
                                    Get.textTheme.bodyText1,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0,
                                    color: MyColors.blackColor.withAlpha(100)),
                                hintText:show==0? "User Full Name*":getFullName(),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.all(15),
                              ),
                              autofocus: false,
                              //controller: fullNameController,
                              // onChanged: (value) {
                              //   setState(() {
                              //     fullName = value;
                              //   });
                              // },
                            ),
                          ),
                          //for user name
                          Container(
                            margin: EdgeInsets.only(
                                left: MySizes.padding15,
                                right: MySizes.padding15,
                                top: 30),
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
                            child: TextFormField(
                              obscureText: false,
                              style: MyComponents.myTextStyle(
                                  Get.textTheme.bodyText1,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.2),
                              decoration: InputDecoration(
                                hintStyle: MyComponents.myTextStyle(
                                    Get.textTheme.bodyText1,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0,
                                    color: MyColors.blackColor.withAlpha(100)),
                                hintText: "Username*",
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.all(15),
                              ),
                              autofocus: false,
                              //controller: usernameController,
                              onChanged: (value) {
                                setState(() {
                                  username = value;
                                });
                              },
                            ),
                          ),
                          //for user mobile

                          Container(
                            margin: EdgeInsets.only(
                                left: MySizes.padding15,
                                right: MySizes.padding15,
                                top: 30),
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
                            child: TextFormField(
                              obscureText: false,
                              enabled: false,
                              style: MyComponents.myTextStyle(
                                  Get.textTheme.bodyText1,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.2),
                              decoration: InputDecoration(
                                hintStyle: MyComponents.myTextStyle(
                                    Get.textTheme.bodyText1,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0,
                                    color: MyColors.blackColor.withAlpha(100)),
                                hintText:show==0? "Mobile*":getMobile(),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.all(15),
                              ),
                              autofocus: false,

                            ),
                          ),
                          //for user email

                          Container(
                            margin: EdgeInsets.only(
                                left: MySizes.padding15,
                                right: MySizes.padding15,
                                top: 30),
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
                            child: TextFormField(
                              obscureText: false,
                              enabled: false,
                              style: MyComponents.myTextStyle(
                                  Get.textTheme.bodyText1,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.2),
                              decoration: InputDecoration(
                                hintStyle: MyComponents.myTextStyle(
                                    Get.textTheme.bodyText1,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0,
                                    color: MyColors.blackColor.withAlpha(100)),
                                hintText:show==0? "Email":getEmail(),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.all(15),
                              ),
                              autofocus: false,
                              //controller: fullNameController,
                              // onChanged: (value) {
                              //   setState(() {
                              //     fullName = value;
                              //   });
                              // },
                            ),
                          ),
                          //for user age

                          Container(
                            margin: EdgeInsets.only(
                                left: MySizes.padding15,
                                right: MySizes.padding15,
                                top: 30),
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
                            child: TextFormField(
                              obscureText: false,
                              enabled: false,
                              style: MyComponents.myTextStyle(
                                  Get.textTheme.bodyText1,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.2),
                              decoration: InputDecoration(
                                hintStyle: MyComponents.myTextStyle(
                                    Get.textTheme.bodyText1,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0,
                                    color: MyColors.blackColor.withAlpha(100)),
                                hintText:show==0? "Age*":getAge(),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.all(15),
                              ),
                              autofocus: false,

                            ),
                          ),
                          //for country

                          Container(
                            margin: EdgeInsets.only(
                                left: MySizes.padding15,
                                right: MySizes.padding15,
                                top: 30),
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
                            child: TextFormField(
                              obscureText: false,
                              style: MyComponents.myTextStyle(Get.textTheme.bodyText1,
                                  fontWeight: FontWeight.w500, letterSpacing: 0.2),
                              decoration: InputDecoration(
                                enabled: false,
                                hintStyle: MyComponents.myTextStyle(
                                    Get.textTheme.bodyText1,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0,
                                    color: MyColors.blackColor.withAlpha(100)),
                                hintText: show == 0 ? 'Country' : getCountry(),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.all(15),
                              ),
                              autofocus: false,
                            ),
                          ),
                          //for password
                          Container(
                            margin: EdgeInsets.only(
                                left: MySizes.padding15,
                                right: MySizes.padding15,
                                top: 30),
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
                            child: TextFormField(
                              obscureText: true,
                              style: MyComponents.myTextStyle(
                                  Get.textTheme.bodyText1,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.2),
                              decoration: InputDecoration(
                                hintStyle: MyComponents.myTextStyle(
                                    Get.textTheme.bodyText1,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0,
                                    color: MyColors.blackColor.withAlpha(100)),
                                hintText: "Password*",
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.all(15),
                              ),
                              autofocus: false,
                              //controller: passwordController,
                              onChanged: (value) {
                                setState(() {
                                  password = value;
                                });
                              },
                            ),
                          ),
                          //for confirm password
                          Container(
                            margin: EdgeInsets.only(
                                left: MySizes.padding15,
                                right: MySizes.padding15,
                                top: 30),
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
                            child: TextFormField(
                              obscureText: true,
                              style: MyComponents.myTextStyle(
                                  Get.textTheme.bodyText1,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.2),
                              decoration: InputDecoration(
                                hintStyle: MyComponents.myTextStyle(
                                    Get.textTheme.bodyText1,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0,
                                    color: MyColors.blackColor.withAlpha(100)),
                                hintText: "Confirm Password*",
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.all(15),
                              ),
                              autofocus: false,
                              //controller: confirmPasswordController,
                              onChanged: (value) {
                                setState(() {
                                  confirmPassword = value;
                                });
                              },
                            ),
                          ),
                          //for transaction password
                          Container(
                            margin: EdgeInsets.only(
                                left: MySizes.padding15,
                                right: MySizes.padding15,
                                top: 30),
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
                            child: TextFormField(
                              obscureText: true,
                              style: MyComponents.myTextStyle(
                                  Get.textTheme.bodyText1,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.2),
                              decoration: InputDecoration(
                                hintStyle: MyComponents.myTextStyle(
                                    Get.textTheme.bodyText1,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0,
                                    color: MyColors.blackColor.withAlpha(100)),
                                hintText: "Transaction Password*",
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.all(15),
                              ),
                              autofocus: false,
                              onChanged: (value) {
                                setState(() {
                                  transactionPassword = value;
                                });
                              },
                            ),
                          ),
                          //for products
                          Container(
                            margin: EdgeInsets.only(
                                left: MySizes.padding15,
                                right: MySizes.padding15,
                                top: 30),
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
                                hintText: '-Select Product-',
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.all(15),
                              ),
                              items: [
                                for (int i = 0;
                                i < productInfo.length;
                                i++) ...{
                                  productInfo[i]['name'],
                                }
                              ],
                                onChanged: (v) {
                                  selectProduct = v!;
                                  showPrice = 1;
                                  getProductPrice();
                                  getProductId();
                                }
                            ),
                          ),
                          //for product price
                          Container(
                            margin: EdgeInsets.only(
                                left: MySizes.padding15,
                                right: MySizes.padding15,
                                top: 30),
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
                            child: TextFormField(
                              obscureText: false,
                              style: MyComponents.myTextStyle(Get.textTheme.bodyText1,
                                  fontWeight: FontWeight.w500, letterSpacing: 0.2),
                              decoration: InputDecoration(
                                enabled: false,
                                hintStyle: MyComponents.myTextStyle(
                                    Get.textTheme.bodyText1,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0,
                                    color: MyColors.blackColor.withAlpha(100)),
                                hintText: showPrice == 0 ? '' : getProductPrice(),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.all(15),
                              ),
                              autofocus: false,

                            ),
                          ),
                          const SizedBox(height: 30,)
                        ],
                      ),
                    ),
                  ),
                ))
          ],
        ),
      ),
      bottomNavigationBar:double.parse(availableBalance??'0')<=0?const SizedBox(): Container(
        height: 40,
        margin: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(48)),
          boxShadow: [
            BoxShadow(
              color: MyColors.primary.withAlpha(80),
              blurRadius: 5,
              offset: const Offset(0, 5), // changes position of shadow
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(primary: MyColors.primary),
          onPressed: () async {
            existingAddMember();

          },
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: Text(
                  "ADD MEMBER",
                  style: MyComponents.myTextStyle(Get.textTheme.bodyText2,
                      color: MyColors.onPrimary,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w500),
                ),
              ),
              Positioned(
                right: 16,
                child: ClipOval(
                  child: Container(
                    color: MyColors.primaryVariant,
                    // button color
                    child: SizedBox(
                        width: 25,
                        height: 25,
                        child: Icon(
                          MdiIcons.arrowRight,
                          color: MyColors.onPrimary,
                          size: 15,
                        )),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ):noInternetConnection();
  }
}
