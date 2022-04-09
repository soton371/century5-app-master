import 'dart:convert';

import 'package:century5/config/my_api.dart';
import 'package:century5/config/my_colors.dart';
import 'package:century5/config/my_components.dart';
import 'package:century5/config/my_sizes.dart';
import 'package:century5/views/auth/signin_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {

  String username = '';
  String email = '';

  //for sendPasswordResetEmail
  Future hitSendPasswordResetEmail() async{
    var url = Uri.parse(MyApi.sendPasswordResetEmail);
    var response = await http.post(url,body: {'username':username,'email':email});

    switch(json.decode(response.body)['status']){
      case 0:
        {
          Get.snackbar(json.decode(response.body)['message'],json.decode(response.body)['data'], colorText: Colors.red);
        }
        break;
      default:
        {
          Get.defaultDialog(
              title: 'Check in your mail',
              titleStyle: MyComponents.myTextStyle(
                  Get.textTheme.headlineSmall,
                  fontWeight: FontWeight.w500),
              content: Text('We just emailed you with the instructions to reset your password',
                style: MyComponents.myTextStyle(
                  Get.textTheme.titleMedium,
                ),
                textAlign: TextAlign.center,
              ),
              textConfirm: 'OK',
              confirmTextColor: Colors.white,
              onConfirm: ()=>Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>SignInScreen()))
          );
        }
        break;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView(
          shrinkWrap: true,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const BouncingScrollPhysics(),
          children: [
            //for title
            Text(
              "Forgot your password?",
              softWrap: true,
              style: MyComponents.myTextStyle(Get.textTheme.headlineSmall,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                  color: MyColors.blackColor.withAlpha(160)),
              textAlign: TextAlign.center,
            ),
            Container(
              margin: const EdgeInsets.only(left: 10, right: 10, top: 20),
              child: Text(
                "Enter your username & email address and we'll send mail to reset your password",
                softWrap: true,
                style: MyComponents.myTextStyle(Get.textTheme.bodyText1,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                    color: MyColors.blackColor.withAlpha(160)),
                textAlign: TextAlign.center,
              ),
            ),

            //for input fields
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
                        hintText: "Username",
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.all(15),
                      ),
                      autofocus: false,
                      keyboardType: TextInputType.emailAddress,
                      //controller: controller.emailController,
                      onChanged: (value){
                        username = value;
                      },

                    ),
                    Divider(
                      color: MyColors.shadowColor,
                      height: 0.5,
                    ),
                    TextFormField(
                      //controller: controller.passwordController,
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
                        hintText: "Email address",
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
                        email = value;
                      },
                    )
                  ],
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
                    hitSendPasswordResetEmail();
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
      ),
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
