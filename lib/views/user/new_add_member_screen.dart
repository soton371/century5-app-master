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
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class NewAddMemberScreen extends StatefulWidget {
  const NewAddMemberScreen({Key? key}) : super(key: key);

  @override
  _NewAddMemberScreenState createState() => _NewAddMemberScreenState();
}

class _NewAddMemberScreenState extends State<NewAddMemberScreen> {
  final GlobalKey<FormState> newAddMemberKey = GlobalKey<FormState>();

  //for data received
  var fullNameController = TextEditingController(),
      usernameController = TextEditingController(),
      mobileController = TextEditingController(),
      emailController = TextEditingController(),
      ageController = TextEditingController(),
      transactionPasswordController = TextEditingController(),
      confirmPasswordController = TextEditingController(),
      passwordController = TextEditingController();

  //for store value
  var currentUser,
      sponsors,
      selectSponsor,
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
      productId='0';

  var show = 0;

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
    //newAddMember();
    // TODO: implement initState
    super.initState();
  }

  //for profile pic
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
      //productId = json.decode(response.body)['data']['products']['id'].toString();
    });
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

  Future newAddMember() async {
    newAddMemberKey.currentState!.save();
    var url = Uri.parse(MyApi.newAddMember);
    var response = await http.post(url, body: {
      "sponsor": selectSponsor ?? '',
      "username": username ?? '',
      "name": fullName ?? '',
      "mobile": mobile ?? '',
      "email": email ?? '',
      "age": age ?? '',
      "country": selectCountry ?? '',
      'product_id': productId != null ? productId : '0',
      "password": password ?? '',
      "password_confirmation": confirmPassword ?? '',
      "transaction_password": transactionPassword ?? '',
      "product":selectProduct ?? '',
      "price": productPrice != null ? productPrice : '00.0',

    }, headers: {
      "Accept": "application/json",
      HttpHeaders.authorizationHeader: 'Bearer ${controller.token}',
    });

    switch (json.decode(response.body)['status']) {
      case 1:
        {
          print(json.decode(response.body)['message']);
          Get.snackbar(json.decode(response.body)['message'], 'Add new member');
        }
        break;
      default:
        {
          print(json.decode(response.body)['message']);
          Get.snackbar(
              json.decode(response.body)['message'], json.decode(response.body)['data']);
        }
        break;
    }
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return status ? Scaffold(
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
                        "   ৳${availableBalance}",
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
                borderRadius: const BorderRadius.vertical(top: const Radius.circular(18)),
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
                      //for full name
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
                            hintText: "User Full Name",
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.all(15),
                          ),
                          autofocus: false,
                          controller: fullNameController,
                          onChanged: (value) {
                            setState(() {
                              fullName = value;
                            });
                          },
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
                            hintText: "Username",
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.all(15),
                          ),
                          autofocus: false,
                          controller: usernameController,
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
                          keyboardType: TextInputType.phone,
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
                            hintText: "Mobile",
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.all(15),
                          ),
                          autofocus: false,
                          controller: mobileController,
                          onChanged: (value) {
                            setState(() {
                              mobile = value;
                            });
                          },
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
                          keyboardType: TextInputType.emailAddress,
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
                            hintText: "Type Email",
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.all(15),
                          ),
                          autofocus: false,
                          controller: emailController,
                          onChanged: (value) {
                            setState(() {
                              email = value;
                            });
                          },
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
                          keyboardType: TextInputType.number,
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
                            hintText: "Type Member Age",
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.all(15),
                          ),
                          autofocus: false,
                          controller: ageController,
                          onChanged: (value) {
                            setState(() {
                              age = value;
                            });
                          },
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
                            hintText: '-Select Country-',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.all(15),
                          ),
                          items: const[
                            "Afghanistan",
                            "Albania",
                            "Algeria",
                            "American Samoa",
                            "Andorra",
                            "Angola",
                            "Anguilla",
                            "Antarctica",
                            "Antigua and Barbuda",
                            "Argentina",
                            "Armenia",
                            "Aruba",
                            "Australia",
                            "Austria",
                            "Azerbaijan",
                            "Bahamas (the)",
                            "Bahrain",
                            "Bangladesh",
                            "Barbados",
                            "Belarus",
                            "Belgium",
                            "Belize",
                            "Benin",
                            "Bermuda",
                            "Bhutan",
                            "Bolivia (Plurinational State of)",
                            "Bonaire, Sint Eustatius and Saba",
                            "Bosnia and Herzegovina",
                            "Botswana",
                            "Bouvet Island",
                            "Brazil",
                            "British Indian Ocean Territory (the)",
                            "Brunei Darussalam",
                            "Bulgaria",
                            "Burkina Faso",
                            "Burundi",
                            "Cabo Verde",
                            "Cambodia",
                            "Cameroon",
                            "Canada",
                            "Cayman Islands (the)",
                            "Central African Republic (the)",
                            "Chad",
                            "Chile",
                            "China",
                            "Christmas Island",
                            "Cocos (Keeling) Islands (the)",
                            "Colombia",
                            "Comoros (the)",
                            "Congo (the Democratic Republic of the)",
                            "Congo (the)",
                            "Cook Islands (the)",
                            "Costa Rica",
                            "Croatia",
                            "Cuba",
                            "Curaçao",
                            "Cyprus",
                            "Czechia",
                            "Côte d'Ivoire",
                            "Denmark",
                            "Djibouti",
                            "Dominica",
                            "Dominican Republic (the)",
                            "Ecuador",
                            "Egypt",
                            "El Salvador",
                            "Equatorial Guinea",
                            "Eritrea",
                            "Estonia",
                            "Eswatini",
                            "Ethiopia",
                            "Falkland Islands (the) [Malvinas]",
                            "Faroe Islands (the)",
                            "Fiji",
                            "Finland",
                            "France",
                            "French Guiana",
                            "French Polynesia",
                            "French Southern Territories (the)",
                            "Gabon",
                            "Gambia (the)",
                            "Georgia",
                            "Germany",
                            "Ghana",
                            "Gibraltar",
                            "Greece",
                            "Greenland",
                            "Grenada",
                            "Guadeloupe",
                            "Guam",
                            "Guatemala",
                            "Guernsey",
                            "Guinea",
                            "Guinea-Bissau",
                            "Guyana",
                            "Haiti",
                            "Heard Island and McDonald Islands",
                            "Holy See (the)",
                            "Honduras",
                            "Hong Kong",
                            "Hungary",
                            "Iceland",
                            "India",
                            "Indonesia",
                            "Iran (Islamic Republic of)",
                            "Iraq",
                            "Ireland",
                            "Isle of Man",
                            "Israel",
                            "Italy",
                            "Jamaica",
                            "Japan",
                            "Jersey",
                            "Jordan",
                            "Kazakhstan",
                            "Kenya",
                            "Kiribati",
                            "Korea (the Democratic People's Republic of)",
                            "Korea (the Republic of)",
                            "Kuwait",
                            "Kyrgyzstan",
                            "Lao People's Democratic Republic (the)",
                            "Latvia",
                            "Lebanon",
                            "Lesotho",
                            "Liberia",
                            "Libya",
                            "Liechtenstein",
                            "Lithuania",
                            "Luxembourg",
                            "Macao",
                            "Madagascar",
                            "Malawi",
                            "Malaysia",
                            "Maldives",
                            "Mali",
                            "Malta",
                            "Marshall Islands (the)",
                            "Martinique",
                            "Mauritania",
                            "Mauritius",
                            "Mayotte",
                            "Mexico",
                            "Micronesia (Federated States of)",
                            "Moldova (the Republic of)",
                            "Monaco",
                            "Mongolia",
                            "Montenegro",
                            "Montserrat",
                            "Morocco",
                            "Mozambique",
                            "Myanmar",
                            "Namibia",
                            "Nauru",
                            "Nepal",
                            "Netherlands (the)",
                            "New Caledonia",
                            "New Zealand",
                            "Nicaragua",
                            "Niger (the)",
                            "Nigeria",
                            "Niue",
                            "Norfolk Island",
                            "Northern Mariana Islands (the)",
                            "Norway",
                            "Oman",
                            "Pakistan",
                            "Palau",
                            "Palestine, State of",
                            "Panama",
                            "Papua New Guinea",
                            "Paraguay",
                            "Peru",
                            "Philippines (the)",
                            "Pitcairn",
                            "Poland",
                            "Portugal",
                            "Puerto Rico",
                            "Qatar",
                            "Republic of North Macedonia",
                            "Romania",
                            "Russian Federation (the)",
                            "Rwanda",
                            "Réunion",
                            "Saint Barthélemy",
                            "Saint Helena, Ascension and Tristan da Cunha",
                            "Saint Kitts and Nevis",
                            "Saint Lucia",
                            "Saint Martin (French part)",
                            "Saint Pierre and Miquelon",
                            "Saint Vincent and the Grenadines",
                            "Samoa",
                            "San Marino",
                            "Sao Tome and Principe",
                            "Saudi Arabia",
                            "Senegal",
                            "Serbia",
                            "Seychelles",
                            "Sierra Leone",
                            "Singapore",
                            "Sint Maarten (Dutch part)",
                            "Slovakia",
                            "Slovenia",
                            "Solomon Islands",
                            "Somalia",
                            "South Africa",
                            "South Georgia and the South Sandwich Islands",
                            "South Sudan",
                            "Spain",
                            "Sri Lanka",
                            "Sudan (the)",
                            "Suriname",
                            "Svalbard and Jan Mayen",
                            "Sweden",
                            "Switzerland",
                            "Syrian Arab Republic",
                            "Taiwan",
                            "Tajikistan",
                            "Tanzania, United Republic of",
                            "Thailand",
                            "Timor-Leste",
                            "Togo",
                            "Tokelau",
                            "Tonga",
                            "Trinidad and Tobago",
                            "Tunisia",
                            "Turkey",
                            "Turkmenistan",
                            "Turks and Caicos Islands (the)",
                            "Tuvalu",
                            "Uganda",
                            "Ukraine",
                            "United Arab Emirates (the)",
                            "United Kingdom of Great Britain and Northern Ireland (the)",
                            "United States Minor Outlying Islands (the)",
                            "United States of America (the)",
                            "Uruguay",
                            "Uzbekistan",
                            "Vanuatu",
                            "Venezuela (Bolivarian Republic of)",
                            "Viet Nam",
                            "Virgin Islands (British)",
                            "Virgin Islands (U.S.)",
                            "Wallis and Futuna",
                            "Western Sahara",
                            "Yemen",
                            "Zambia",
                            "Zimbabwe",
                            "Åland Islands"
                          ],
                          onChanged: (v)=>selectCountry=v,
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
                            hintText: "Password",
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.all(15),
                          ),
                          autofocus: false,
                          controller: passwordController,
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
                            hintText: "Confirm Password",
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.all(15),
                          ),
                          autofocus: false,
                          controller: confirmPasswordController,
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
                            hintText: "Transaction Password",
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.all(15),
                          ),
                          autofocus: false,
                          controller: transactionPasswordController,
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
                            show = 1;
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
                            hintText: show == 0 ? '' : getProductPrice(),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.all(15),
                          ),
                          autofocus: false,
                          // onChanged: (v)=>productPrice=v,
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
            newAddMember().then((value) {
              fullNameController.text = '';
              usernameController.text = '';
              mobileController.text = '';
              emailController.text = '';
              ageController.text = '';
              passwordController.text = '';
              confirmPasswordController.text = '';
              transactionPasswordController.text = '';
            });
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

