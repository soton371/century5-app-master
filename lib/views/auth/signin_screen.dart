import 'dart:async';

import 'package:century5/config/my_colors.dart';
import 'package:century5/config/my_components.dart';
import 'package:century5/config/my_sizes.dart';
import 'package:century5/controllers/auth_controller.dart';
import 'package:century5/views/forgot_password/forgot_password_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class SignInScreen extends StatefulWidget {
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  //const SignInScreen({Key? key}) : super(key: key);
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
    return Column(
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
    return Scaffold(
      body:status? Center(
        child: ListView(
          shrinkWrap: true,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const BouncingScrollPhysics(),
          children: <Widget>[
            const Center(
                child: Image(
                  image: AssetImage("assets/images/logo.png"),
                  width: 180,
                )),
            Container(
              margin: const EdgeInsets.only(left: 48, right: 48, top: 20),
              child: Text(
                "Enter your login details to access your account",
                softWrap: true,
                style: MyComponents.myTextStyle(Get.textTheme.bodyText1,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                    color: MyColors.blackColor.withAlpha(160)),
                textAlign: TextAlign.center,
              ),
            ),
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
                  key: controller.loginFormKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        style: MyComponents.myTextStyle(Get.textTheme.bodyText1,
                            fontWeight: FontWeight.w500, letterSpacing: 0.2),
                        decoration: InputDecoration(
                          hintStyle: MyComponents.myTextStyle(
                              Get.textTheme.bodyText1,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0,
                              color: MyColors.blackColor.withAlpha(100)),
                          hintText: "Email Address",
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.all(15),
                        ),
                        autofocus: false,
                        keyboardType: TextInputType.emailAddress,
                        controller: controller.emailController,
                        onChanged: (value){
                          controller.email = value;
                        },
                        // onSaved: (value) {
                        //   controller.email = value!;
                        // },
                      ),
                      Divider(
                        color: MyColors.shadowColor,
                        height: 0.5,
                      ),
                      TextFormField(
                        controller: controller.passwordController,
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
                          hintText: "Your Password",
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
                        onChanged: (value){
                          controller.password = value;
                        },
                        // onSaved: (value) {
                        //   controller.password = value!;
                        // },
                      )
                    ],
                  ),
                ),
              ),
            ),
            //for forgot password
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_)=>const ForgotPasswordScreen()));
                  },
                  child: Text("FORGOT PASSWORD?",
                      style: MyComponents.myTextStyle(
                          Get.textTheme.labelMedium,
                          letterSpacing: 0.5,
                          color: MyColors.blackColor.withAlpha(100),
                          fontWeight: FontWeight.w500)),
                ),
              ),
            ),
            //for button
            Container(
              margin: const EdgeInsets.only(left: 15, right: 15, top: 15),
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
                    controller.checkLogin();
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          "CONTINUE",
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
      ):Center(child: noInternetConnection()),
      bottomNavigationBar: Container(
        height: 30,
        alignment: Alignment.center,
        padding: const EdgeInsets.only(bottom: 10),
        child: Text('Powered by Smart Software Ltd.',
          style: MyComponents.myTextStyle(Get.textTheme.bodyText1,
              fontWeight: FontWeight.w500,
              height: 1.2,
              color: MyColors.blackColor.withAlpha(100)),
        ),
      ),
    );
  }
}


