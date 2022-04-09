import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:century5/config/my_api.dart';
import 'package:century5/config/my_colors.dart';
import 'package:century5/config/my_components.dart';
import 'package:century5/config/my_sizes.dart';
import 'package:century5/controllers/auth_controller.dart';
import 'package:century5/widgets/my_drawer_widget.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:http/http.dart' as http;

class WalletTransferScreen extends StatefulWidget {
  const WalletTransferScreen({Key? key}) : super(key: key);

  @override
  _WalletTransferScreenState createState() => _WalletTransferScreenState();
}

class _WalletTransferScreenState extends State<WalletTransferScreen> {

  double xOffset = 0;
  double yOffset = 0;
  double scaleFactor = 1;
  bool isDrawerOpen = false;

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
    // TODO: implement initState
    super.initState();
    fetchWalletTransferList();
    fetchWalletTransferCreateData();
  }


  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }


//for fetch wallet transfer list
  var invoiceNo, date, percent, remarks, amount, deduction;
  List walletTransferList = [];

  Future fetchWalletTransferList() async {
    var url = Uri.parse(MyApi.getWalletTransferList);
    var response = await http.post(url, headers: {
      "Accept": "application/json",
      HttpHeaders.authorizationHeader: 'Bearer ${controller.token}',
    });

    switch (json.decode(response.body)['status']) {
      case 1:
        {
          setState(() {
            walletTransferList = json.decode(response.body)['data']['data'];
          });
        }
        break;
      default:
        {
          //print(json.decode(response.body)['message']);
          Get.snackbar(
              json.decode(response.body)['message'], "Something wrong", colorText: Colors.red);
        }
        break;
    }
  }

  //for available balance
  String availableBalance = '';

  Future fetchWalletTransferCreateData() async {
    var url = Uri.parse(MyApi.getWalletTransferCreateData);
    var response = await http.post(url, headers: {
      "Accept": "application/json",
      HttpHeaders.authorizationHeader: 'Bearer ${controller.token}',
    });

    switch (json.decode(response.body)['status']) {
      case 1:
        {
          setState(() {
            availableBalance = json.decode(response.body)['data']['availableCurrentWalletBalance'].toString();
          });
        }
        break;
      default:
        {
          //print(json.decode(response.body)['message']);
          Get.snackbar(
              json.decode(response.body)['message'], "Something wrong", colorText: Colors.red);
        }
        break;
    }
  }

  //add wallet transfer
  var sendAmountController = TextEditingController();
  var sendRemarksController = TextEditingController();
  String selectWallet='';
  String sendAmount = '';
  String userId = '';
  String sendRemarks = '';
  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future sendStoreWalletTransfer() async {

    var url = Uri.parse(MyApi.storeWalletTransfer);
    var response = await http.post(url, headers: {
      "Accept": "application/json",
      HttpHeaders.authorizationHeader: 'Bearer ${controller.token}',
    }, body: {
      'wallet': selectWallet,
      'date': formattedDate,
      'amount': sendAmount,
      'remarks':sendRemarks
    });

    switch (json.decode(response.body)['status']) {
      case 1:
        {
          //print(json.decode(response.body)['message']);
          Navigator.of(context,
              rootNavigator: true)
              .pop();
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                  const WalletTransferScreen()));
          Get.snackbar('Thanks', "Your balance transfer has been sent successfully");
        }
        break;
      default:
        {
          //print(json.decode(response.body)['message']);
          Get.snackbar(
              json.decode(response.body)['message'], "Something wrong",colorText: Colors.red);
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return status? Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.fullAABackground,
        elevation: 0,
        titleSpacing: 0,
        title: Text("Wallet Transfer",
          style: MyComponents.myTextStyle(
            Get.textTheme.headline6,
          ),
        ),
        actions: [
              IconButton(
                  onPressed: () => Get.defaultDialog(
                      title: 'Available ৳$availableBalance',
                      content: double.parse(availableBalance.toString()) <= 0
                          ? Text(
                        "Sorry! You do not have the available balance in your current wallet. The minimum limit is 200 tk.",
                        style: MyComponents.myTextStyle(
                          Get.textTheme.titleMedium,
                        ),
                        textAlign: TextAlign.center,
                      )
                          : SingleChildScrollView(
                        child: Column(
                          children: [
                            //select wallet
                            Container(
                              margin: const EdgeInsets.only(bottom: 15),
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
                                  hintText: "Select Wallet",
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.all(15),
                                ),
                                items: const [
                                  'My Balance',
                                ],
                                onChanged: (v)=>selectWallet=v!,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(
                                  bottom: 15),
                              decoration: BoxDecoration(
                                  color: MyColors.background,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(15)),
                                  boxShadow: [
                                    BoxShadow(
                                        blurRadius: 8.0,
                                        color: MyColors.shadowColor
                                            .withAlpha(25),
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
                                      color: MyColors.blackColor
                                          .withAlpha(100)),
                                  hintText: "Amount*",
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.all(15),
                                ),
                                autofocus: false,
                                controller: sendAmountController,
                                onChanged: (value) {
                                  sendAmount = value;
                                },
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(
                                  bottom: 10),
                              decoration: BoxDecoration(
                                  color: MyColors.background,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(15)),
                                  boxShadow: [
                                    BoxShadow(
                                        blurRadius: 8.0,
                                        color: MyColors.shadowColor
                                            .withAlpha(25),
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
                                      color: MyColors.blackColor
                                          .withAlpha(100)),
                                  hintText: "Remarks",
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.all(15),
                                ),
                                autofocus: false,
                                controller: sendRemarksController,
                                onChanged: (value) {
                                  sendRemarks = value;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        int.parse(availableBalance.toString()) <= 0
                            ? const SizedBox()
                            :
                        Container(
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
                              sendStoreWalletTransfer().then((value) {
                                sendAmountController.text = '';
                                sendRemarksController.text = '';
                              });
                            },
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Balance Send",
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
                      ]
                  ),
                  icon: Icon(
                    Icons.add,
                    color: MyColors.secondaryVariant,
                  )),

        ],
      ),
      drawer: const MyDrawerWidget(),
      body:walletTransferList.isEmpty
          ? const Center(child: Text('No wallet transfer has taken place yet'))
          : ListView.builder(
          itemCount: walletTransferList.length,
          itemBuilder: (_, index) {
            date = walletTransferList[index]['date'];
            invoiceNo = walletTransferList[index]['invoice_no'];
            amount = walletTransferList[index]['amount'];
            percent = walletTransferList[index]['percent'];
            deduction = walletTransferList[index]['deduction'];
            remarks = walletTransferList[index]['remarks'];

            return Slidable(
              actionPane: const SlidableDrawerActionPane(),
              secondaryActions: [
                IconSlideAction(
                  iconWidget: Container(
                    height: 50,
                    width: 50,decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.all(
                        Radius.circular(MySizes.size15)),
                    boxShadow: [
                      BoxShadow(
                        color: MyColors.shadowColor.withAlpha(26),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                    child: const Icon(FontAwesomeIcons.solidTrashAlt,color: Colors.white,),
                  ),
                  color: Colors.transparent,
                  onTap: ()async{
                    //for delete
                    var url = Uri.parse(MyApi.walletTransferDelete);
                    var response = await http.post(url, headers: {
                      "Accept": "application/json",
                      HttpHeaders.authorizationHeader: 'Bearer ${controller.token}',
                    },
                        body: {
                          'transfer_id': walletTransferList[index]['id'].toString()
                        }
                    );

                    switch (json.decode(response.body)['status']) {
                      case 1:
                        {
                          //for remove to ui
                          setState(() {
                            walletTransferList.removeAt(index);
                          });
                          //print(json.decode(response.body)['message']);
                          Get.snackbar(
                              json.decode(response.body)['message'], "Delete form wallet transfer list");
                        }
                        break;
                      default:
                        {
                          //print(json.decode(response.body)['message']);
                          Get.snackbar(
                              json.decode(response.body)['message'], "Something wrong", colorText: Colors.red);
                        }
                        break;
                    }
                  },
                )
              ],
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 15, vertical: 15),
                margin: EdgeInsets.only(
                    top: MySizes.size15,
                    left: MySizes.size15,
                    right: MySizes.size15),
                decoration: BoxDecoration(
                  color: MyColors.background,
                  borderRadius: BorderRadius.all(
                      Radius.circular(MySizes.size15)),
                  boxShadow: [
                    BoxShadow(
                      color: MyColors.shadowColor.withAlpha(26),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          invoiceNo,
                          style: MyComponents.myTextStyle(
                              Get.textTheme.titleMedium,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          date,
                          style: MyComponents.myTextStyle(
                            Get.textTheme.caption,
                          ),
                        ),
                        Text(
                          remarks??'',
                          style: MyComponents.myTextStyle(
                            Get.textTheme.caption,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          amount,
                          style: MyComponents.myTextStyle(
                              Get.textTheme.titleMedium,
                              fontWeight: FontWeight.w500),
                        ),
                        Text('$deduction(${percent.toString()}%)',
                          style: MyComponents.myTextStyle(
                              Get.textTheme.caption,
                              color: MyColors.secondaryVariant),
                        ),

                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
    ):noInternetConnection();
  }
}
