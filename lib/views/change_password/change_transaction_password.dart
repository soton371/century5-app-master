import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:century5/config/my_api.dart';
import 'package:century5/config/my_colors.dart';
import 'package:century5/config/my_components.dart';
import 'package:century5/config/my_sizes.dart';
import 'package:century5/controllers/auth_controller.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:http/http.dart' as http;

class ChangeTransactionPasswordScreen extends StatefulWidget {
  const ChangeTransactionPasswordScreen({Key? key}) : super(key: key);

  @override
  _ChangeTransactionPasswordScreenState createState() => _ChangeTransactionPasswordScreenState();
}

class _ChangeTransactionPasswordScreenState extends State<ChangeTransactionPasswordScreen> {

  var currentTransactionPasswordController = TextEditingController();
  var newTransactionPasswordController = TextEditingController();
  var confirmTransactionPasswordController = TextEditingController();

  String currentTransactionPassword = '';
  String newTransactionPassword = '';
  String confirmTransactionPassword = '';

  var controller = Get.put(AuthController());

  //for update transaction password
  Future sendUserPasswordUpdate() async {

    var url = Uri.parse(MyApi.transactionPasswordUpdate);
    var response = await http.post(url, headers: {
      "Accept": "application/json",
      HttpHeaders.authorizationHeader: 'Bearer ${controller.token}',
    }, body: {
      'current_transaction_password': currentTransactionPassword,
      'new_transaction_password': newTransactionPassword,
      'confirm_transaction_password': confirmTransactionPassword,
    });

    switch (json.decode(response.body)['status']) {
      case 1:
        {
          //print(json.decode(response.body)['message']);
          Get.snackbar(json.decode(response.body)['message'], "Update Password");
        }
        break;
      default:
        {
          //print(json.decode(response.body)['message']);
          Get.snackbar(
              json.decode(response.body)['message'], json.decode(response.body)['data'],
              colorText: Colors.red
          );
        }
        break;
    }
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
    checkRealtimeConnection();
    // TODO: implement initState
    super.initState();
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
        titleSpacing: 0,
        elevation: 0,
        title: Text("Change Transaction Password",
          style: MyComponents.myTextStyle(
            Get.textTheme.headline6,
          ),
        ),
        leading: InkWell(
            onTap: ()=>Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios)
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Image(image: AssetImage("assets/images/change_sign_password.png")),
              Container(
                margin: EdgeInsets.only(
                    left: MySizes.padding15, right: MySizes.padding15, top: 30),
                child: Container(
                  decoration: BoxDecoration(
                      color: MyColors.background,
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      boxShadow: [
                        BoxShadow(
                            blurRadius: 8.0,
                            color: MyColors.shadowColor.withAlpha(25),
                            offset: const Offset(0, 3)),
                      ]),
                  child: Form(
                    //key: controller.loginFormKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          obscureText: true,
                          style: MyComponents.myTextStyle(Get.textTheme.bodyText1,
                              fontWeight: FontWeight.w500, letterSpacing: 0.2),
                          decoration: InputDecoration(
                            hintStyle: MyComponents.myTextStyle(
                                Get.textTheme.bodyText1,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0,
                                color: MyColors.blackColor.withAlpha(100)),
                            hintText: "Current Transaction Password",
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.all(15),
                          ),
                          autofocus: false,
                          controller: currentTransactionPasswordController,
                          onChanged: (v)=>currentTransactionPassword=v,
                        ),
                        Divider(
                          color: MyColors.shadowColor,
                          height: 0.5,
                        ),
                        TextFormField(
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
                            hintText: "New Transaction Password",
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.all(15),
                          ),
                          autofocus: false,
                          textInputAction: TextInputAction.search,
                          textCapitalization: TextCapitalization.sentences,
                          obscureText: true,
                          controller: newTransactionPasswordController,
                          onChanged: (v)=>newTransactionPassword=v,
                        ),
                        Divider(
                          color: MyColors.shadowColor,
                          height: 0.5,
                        ),
                        TextFormField(
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
                            hintText: "Confirm Transaction Password",
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.all(15),
                          ),
                          autofocus: false,
                          textInputAction: TextInputAction.search,
                          textCapitalization: TextCapitalization.sentences,
                          obscureText: true,
                          controller: confirmTransactionPasswordController,
                          onChanged: (v)=>confirmTransactionPassword=v,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              //for button
              Container(
                margin: const EdgeInsets.only(left: 15, right: 15, top: 30,bottom: 30),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(48)),
                    boxShadow: [
                      BoxShadow(
                        color: MyColors.primary.withAlpha(80),
                        blurRadius: 5,
                        offset:
                        const Offset(0, 5), // changes position of shadow
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: MyColors.primary),
                    onPressed: () async {
                      //print("object: $currentPassword, $newPassword, $confirmPassword");
                      sendUserPasswordUpdate().then((value) {
                        currentTransactionPasswordController.text = '';
                        newTransactionPasswordController.text = '';
                        confirmTransactionPasswordController.text = '';
                      });
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Update Password",
                            style: MyComponents.myTextStyle(
                                Get.textTheme.bodyText2,
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
              ),
            ],
          ),
        ),
      ),
    ):noInternetConnection();
  }
}

