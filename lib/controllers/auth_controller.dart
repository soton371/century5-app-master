import 'dart:convert';
import 'package:century5/config/my_api.dart';
import 'package:century5/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:shared_preferences/shared_preferences.dart';



class AuthController extends GetxController{
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  late TextEditingController emailController = TextEditingController(),
      passwordController = TextEditingController();
   var email = '';
   var password = '';
   var token="".obs;
   var myId=0.obs;
   var username = ''.obs;



   @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    checkInternet();
  }

  Future checkInternet()async{
    bool result = await InternetConnectionChecker().hasConnection;
    if(result == false) {
      Get.snackbar("No internet","Please check your internet settings", colorText: Colors.red,duration: const Duration(seconds: 10));
    }
  }

  void checkLogin() async{
    //loginFormKey.currentState!.save();
    print('***************UserName: $email');
    print('***************Password: $password');
    var payload = {"username": email.toString(),"password": password.toString()};
    var url = Uri.parse(MyApi.logInUrl);
    var response = await http.post(url, body: payload);


    switch (json.decode(response.body)['status']){
      case 1:{
        Get.snackbar("Welcome,","The Smart Choice.");
        token.value = json.decode(response.body)['data']['token'];
        myId.value = json.decode(response.body)['data']['user']['profile_id'];
        username.value = json.decode(response.body)['data']['user']['username'];

        //for get token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('myToken', token.value.toString());
        await prefs.setString('userName', email.toString());
        await prefs.setString('password', password.toString());

        Get.to(Body());
      }break;
      default: {
        Get.snackbar(json.decode(response.body)['message'],json.decode(response.body)['data'], colorText: Colors.red);
      } break;
    }
  }
}


