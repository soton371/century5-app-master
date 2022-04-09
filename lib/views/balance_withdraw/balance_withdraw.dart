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
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class BalanceWithdrawScreen extends StatefulWidget {
  const BalanceWithdrawScreen({Key? key}) : super(key: key);

  @override
  _BalanceWithdrawScreenState createState() => _BalanceWithdrawScreenState();
}

class _BalanceWithdrawScreenState extends State<BalanceWithdrawScreen> {
  double xOffset = 0;
  double yOffset = 0;
  double scaleFactor = 1;
  bool isDrawerOpen = false;

  var controller = Get.put(AuthController());

  var receiveAmountController = TextEditingController();
  var transactionPasswordController = TextEditingController();
  var receiveMobileController = TextEditingController();

  var invoiceNo,
      date,
      paymentMethod,
      mobile,
      amount,
      isApproved,
      transactionPassword,
      receiveAmount;
  List withdrawList = [];
  String availableBalance = '';
  String id = '';
  String selectPaymentMethod = '';
  String receiveMobile = '';

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
    fetchBalanceWithdrawList();
    fetchBalanceWithdrawCreateData();
    // TODO: implement initState
    super.initState();
  }

  Future fetchBalanceWithdrawList() async {
    var url = Uri.parse(MyApi.getBalanceWithdrawList);
    var response = await http.post(url, headers: {
      "Accept": "application/json",
      HttpHeaders.authorizationHeader: 'Bearer ${controller.token}',
    });

    switch (json.decode(response.body)['status']) {
      case 1:
        {
          setState(() {
            withdrawList = json.decode(response.body)['data']['data'];
          });
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

  Future sendStoreBalanceWithdraw() async {
    var url = Uri.parse(MyApi.storeBalanceWithdraw);
    var response = await http.post(url, headers: {
      "Accept": "application/json",
      HttpHeaders.authorizationHeader: 'Bearer ${controller.token}',
    }, body: {
      'transaction_password': transactionPassword,
      'amount': receiveAmount,
      'payment_method': selectPaymentMethod,
      'mobile': receiveMobile
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
                  const BalanceWithdrawScreen()));
          Get.snackbar(json.decode(response.body)['message'],
              json.decode(response.body)['data']);
        }
        break;
      default:
        {
          //print(json.decode(response.body)['message']);
          Get.snackbar(json.decode(response.body)['message'],
              json.decode(response.body)['data'], colorText: Colors.red);
        }
        break;
    }
  }

  Future fetchBalanceWithdrawCreateData() async {
    var url = Uri.parse(MyApi.getBalanceWithdrawCreateData);
    var response = await http.post(url, headers: {
      "Accept": "application/json",
      HttpHeaders.authorizationHeader: 'Bearer ${controller.token}',
    });

    switch (json.decode(response.body)['status']) {
      case 1:
        {
          setState(() {
            availableBalance = json
                .decode(response.body)['data']['availableBalance']
                .toString();
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
        elevation: 0,
        titleSpacing: 0,
        title: Text("Balance Withdraw",
          style: MyComponents.myTextStyle(
            Get.textTheme.headline6,
          ),
        ),
        actions: [
              //balance withdraw
              IconButton(
                  onPressed: () => Get.defaultDialog(
                    title: 'Available ৳$availableBalance',
                    content:
                    double.parse(availableBalance)<=0? Text("Sorry! You do not have available balance to your cash wallet.",style: MyComponents.myTextStyle(
                        Get.textTheme.titleMedium,
                        color: double.parse(availableBalance)<0?Colors.red:MyColors.blackColor,
                    ),
                    textAlign: TextAlign.center,
                    ):
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          //for payment method
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
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
                                  hintText: '-Select Payment Method-',
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.all(15),
                                ),
                                items: const [
                                  'Bkash',
                                  'Nagad'
                                ],
                                onChanged: (v) {
                                  selectPaymentMethod = v!;
                                }
                            ),
                          ),
                          //for mobile
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                                color: MyColors.background,
                                borderRadius:
                                const BorderRadius.all(
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
                                    color: MyColors.blackColor
                                        .withAlpha(100)),
                                hintText: "Mobile",
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isDense: true,
                                contentPadding:
                                const EdgeInsets.all(15),
                              ),
                              autofocus: false,
                              controller: receiveMobileController,
                              onChanged: (value) {
                                receiveMobile = value;
                              },
                            ),
                          ),
                          //for amount
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                                color: MyColors.background,
                                borderRadius:
                                const BorderRadius.all(
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
                                    color: MyColors.blackColor
                                        .withAlpha(100)),
                                hintText: "Amount*",
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isDense: true,
                                contentPadding:
                                const EdgeInsets.all(15),
                              ),
                              autofocus: false,
                              controller: receiveAmountController,
                              onChanged: (value) {
                                receiveAmount = value;
                              },
                            ),
                          ),
                          //for transaction password
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                                color: MyColors.background,
                                borderRadius:
                                const BorderRadius.all(
                                    Radius.circular(15)),
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 8.0,
                                      color: MyColors.shadowColor
                                          .withAlpha(25),
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
                                    color: MyColors.blackColor
                                        .withAlpha(100)),
                                hintText: "Transaction Password*",
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isDense: true,
                                contentPadding:
                                const EdgeInsets.all(15),
                              ),
                              autofocus: false,
                              controller:
                              transactionPasswordController,
                              onChanged: (value) {
                                transactionPassword = value;
                              },
                            ),
                          ),
                          Container(
                            height: 40,
                            margin: const EdgeInsets.only(
                                left: 15, right: 15, top: 15),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(48)),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                  MyColors.primary.withAlpha(80),
                                  blurRadius: 5,
                                  offset: const Offset(0,
                                      5), // changes position of shadow
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: MyColors.primary),
                              onPressed: () async {
                                sendStoreBalanceWithdraw()
                                    .then((value) {
                                  transactionPasswordController.text =
                                  '';
                                  receiveAmountController.text = '';
                                  receiveMobileController.text = '';
                                });
                              },
                              child: Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.center,
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Submit",
                                      style: MyComponents.myTextStyle(
                                          Get.textTheme.bodyText2,
                                          color: MyColors.onPrimary,
                                          letterSpacing: 0.8,
                                          fontWeight:
                                          FontWeight.w500),
                                    ),
                                  ),
                                  Positioned(
                                    right: 16,
                                    child: ClipOval(
                                      child: Container(
                                        color:
                                        MyColors.primaryVariant,
                                        // button color
                                        child: SizedBox(
                                            width: 25,
                                            height: 25,
                                            child: Icon(
                                              MdiIcons.arrowRight,
                                              color:
                                              MyColors.onPrimary,
                                              size: 15,
                                            )),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  icon: Icon(
                    Icons.add,
                    color: MyColors.secondaryVariant,
                  )),
        ],
      ),
      drawer: const MyDrawerWidget(),
      body:withdrawList.isEmpty
          ? const Center(child: Text('No balance withdraw has taken place yet'))
          : ListView.builder(
          itemCount: withdrawList.length,
          itemBuilder: (_, index) {
            paymentMethod =
            withdrawList[index]['payment_method'];
            date = withdrawList[index]['date'];
            invoiceNo = withdrawList[index]['invoice_no'];
            mobile = withdrawList[index]['mobile'];
            amount = withdrawList[index]['amount'];
            isApproved = withdrawList[index]['is_approved'];
            id = withdrawList[index]['id'].toString();

            return Slidable(
                actionPane: const SlidableDrawerActionPane(),
                secondaryActions: [
                  isApproved == 1
                      ? const Icon(
                    Icons.add,
                    color: Colors.transparent,
                  )
                      : IconSlideAction(
                    iconWidget: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.all(
                            Radius.circular(
                                MySizes.size12)),
                        boxShadow: [
                          BoxShadow(
                            color: MyColors.shadowColor
                                .withAlpha(26),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        FontAwesomeIcons.solidTrashAlt,
                        color: Colors.white,
                      ),
                    ),
                    color: Colors.transparent,
                    onTap: () async {
                      //for delete
                      var url = Uri.parse(MyApi.balanceWithdrawDelete);
                      var response = await http.post(url, headers: {
                        "Accept": "application/json",
                        HttpHeaders.authorizationHeader: 'Bearer ${controller.token}',
                      },
                          body: {
                            'fund_transfer_id':id
                          }
                      );

                      switch (json.decode(response.body)['status']) {
                        case 1:
                          {
                            //for remove to ui
                            setState(() {
                              withdrawList.removeAt(index);
                            });
                            //print(json.decode(response.body)['message']);
                            Get.snackbar(
                                json.decode(response.body)['message'], 'Delete form balance withdraw');
                          }
                          break;
                        default:
                          {
                            //print(json.decode(response.body)['message']);
                            Get.snackbar(
                                json.decode(response.body)['message'], 'Something wrong',colorText: Colors.red);
                          }
                          break;
                      }
                    },
                  ),
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
                        color:
                        MyColors.shadowColor.withAlpha(26),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            paymentMethod,
                            style: MyComponents.myTextStyle(
                                Get.textTheme.titleMedium,
                                fontWeight: FontWeight.w500),
                          ),
                          Text(
                            mobile,
                            style: MyComponents.myTextStyle(
                              Get.textTheme.caption,
                            ),
                          ),
                          Text(
                            invoiceNo,
                            style: MyComponents.myTextStyle(
                              Get.textTheme.caption,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.end,
                        children: [
                          Text(
                            "৳$amount",
                            style: MyComponents.myTextStyle(
                                Get.textTheme.titleMedium,
                                fontWeight: FontWeight.w500),
                          ),
                          Text(
                            isApproved == 1
                                ? "Approved"
                                : 'Unapproved',
                            style: MyComponents.myTextStyle(
                                Get.textTheme.caption,
                                color:
                                MyColors.secondaryVariant),
                          ),
                          Text(
                            date,
                            style: MyComponents.myTextStyle(
                              Get.textTheme.caption,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ));
          }),
    ):noInternetConnection();
  }
}
