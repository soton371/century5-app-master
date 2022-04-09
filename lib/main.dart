import 'dart:async';
import 'package:century5/controllers/auth_controller.dart';
import 'package:century5/home.dart';
import 'package:century5/views/auth/signin_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
        home:const SplashScreen()
      //home: const ShamolTest(),
    );
  }
}


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  SharedPreferences? prefs;

  var _userId, userName ='', password;

  var controller = Get.put(AuthController());

  startTime() async {
    var _duration = const Duration(seconds: 3);
    return Timer(_duration, _loadUserInfo);
  }

  _loadUserInfo() async {
    if (_userId == "") {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SignInScreen()), (route) => false);
    } else {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Body()), (route) => false);
      controller.password = password.toString();
      controller.email = userName.toString();
      controller.checkLogin();
    }
  }
  sharedPreferences() async{
    prefs = await SharedPreferences.getInstance();
    _userId  = (prefs!.getString('myToken') ?? "");
    userName = (prefs!.getString('userName') ?? "");
    password = (prefs!.getString('password') ?? "");
    // print('My Token $_userId');
    // print('My User Name $userName');
    // print('My Password $password');
  }

  @override
  void initState() {
    super.initState();
    sharedPreferences();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Image(image: AssetImage('assets/images/logo.png'),width: 200),
      ),
    );
  }
}
