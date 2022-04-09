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


class MyBalanceTransferListScreen extends StatefulWidget {
  const MyBalanceTransferListScreen({Key? key}) : super(key: key);

  @override
  _MyBalanceTransferListScreenState createState() =>
      _MyBalanceTransferListScreenState();
}

class _MyBalanceTransferListScreenState
    extends State<MyBalanceTransferListScreen> {
  double xOffset = 0;
  double yOffset = 0;
  double scaleFactor = 1;
  bool isDrawerOpen = false;

  var controller = Get.put(AuthController());

  //for my balance transfer list
  String date = '';
  String invoiceNo = '';
  String receiverId = '';
  String transferTo = '';
  String amount = '';
  List myBalanceTransferList = [];

  Future fetchMyBalanceTransferList() async {
    var url = Uri.parse(MyApi.getMyBalanceTransferList);
    var response = await http.post(url, headers: {
      "Accept": "application/json",
      HttpHeaders.authorizationHeader: 'Bearer ${controller.token}',
    });

    switch (json.decode(response.body)['status']) {
      case 1:
        {
          setState(() {
            myBalanceTransferList = json.decode(response.body)['data']['data'];
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

  //for receiver/transfer to name
  List receiverList = [];
  String availableBalance = '';

  Future fetchMyBalanceTransferCreateData() async {
    var url = Uri.parse(MyApi.getMyBalanceTransferCreateData);
    var response = await http.post(url, headers: {
      "Accept": "application/json",
      HttpHeaders.authorizationHeader: 'Bearer ${controller.token}',
    });

    switch (json.decode(response.body)['status']) {
      case 1:
        {
          setState(() {
            receiverList = json.decode(response.body)['data']['receivers'];
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

  //for add balance transfer
  var sendAmountController = TextEditingController();
  String selectReceiver = '';
  String selectReceiverId = '';
  String sendAmount = '';
  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future sendStoreMyBalanceTransfer() async {
    var url = Uri.parse(MyApi.storeMyBalanceTransfer);
    var response = await http.post(url, headers: {
      "Accept": "application/json",
      HttpHeaders.authorizationHeader: 'Bearer ${controller.token}',
    }, body: {
      'user_id': selectReceiverId,
      'date': formattedDate,
      'amount': sendAmount,
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
                  const MyBalanceTransferListScreen()));
          Get.snackbar('Thanks', "Your request has been sent successfully");
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
    fetchMyBalanceTransferList();
    fetchMyBalanceTransferCreateData();
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
        title: Text("My Balance Transfer",
          style: MyComponents.myTextStyle(
            Get.textTheme.headline6,
          ),
        ),
        actions: [
              IconButton(
                  onPressed: () => Get.defaultDialog(
                    title: 'Available ৳$availableBalance',
                    titleStyle: MyComponents.myTextStyle(
                        Get.textTheme.headlineSmall,
                        color: double.parse(availableBalance) < 0
                            ? Colors.red
                            : MyColors.blackColor,
                        fontWeight: FontWeight.w500),
                    content:double.parse(availableBalance)<0?Text(
                      "Sorry! You do not have the available balance to transfer.",
                      style: MyComponents.myTextStyle(
                        Get.textTheme.titleMedium,
                        color:
                        double.parse(availableBalance.toString()) < 0
                            ? Colors.red
                            : MyColors.blackColor,
                      ),
                      textAlign: TextAlign.center,
                    ):
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          //select receiver
                          Container(
                            margin: const EdgeInsets.only(
                                bottom: 15),
                            decoration: BoxDecoration(
                                color: MyColors.background,
                                borderRadius:
                                const BorderRadius.all(
                                    Radius.circular(15)),
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 8.0,
                                      color: MyColors
                                          .shadowColor
                                          .withAlpha(25),
                                      offset:
                                      const Offset(0, 3)),
                                ]),
                            child: DropdownSearch<String>(
                              dropdownSearchBaseStyle:
                              MyComponents.myTextStyle(
                                  Get.textTheme.bodyText1,
                                  fontWeight:
                                  FontWeight.w500,
                                  letterSpacing: 0.2),
                              popupShape:
                              RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(
                                      15)),
                              mode: Mode.MENU,
                              showSearchBox: true,
                              showAsSuffixIcons: true,
                              dropdownSearchDecoration:
                              InputDecoration(
                                hintStyle:
                                MyComponents.myTextStyle(
                                    Get.textTheme.bodyText1,
                                    fontWeight:
                                    FontWeight.w500,
                                    letterSpacing: 0,
                                    color: MyColors
                                        .blackColor
                                        .withAlpha(100)),
                                hintText: "Select Receiver",
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isDense: true,
                                contentPadding:
                                const EdgeInsets.all(15),
                              ),
                              items: [
                                for (int i = 0;
                                i < receiverList.length;
                                i++) ...{
                                  receiverList[i]['username']
                                }
                              ],
                              onChanged: (v) {
                                selectReceiver = v!;
                                for (int i = 0;
                                i < receiverList.length;
                                i++) {
                                  if (selectReceiver ==
                                      receiverList[i]
                                      ['username']) {
                                    setState(() {
                                      selectReceiverId =
                                          receiverList[i]['id']
                                              .toString();
                                    });
                                  }
                                }
                              },
                            ),
                          ),
                          //for amount
                          Container(
                            margin: const EdgeInsets.only(
                                bottom: 15),
                            decoration: BoxDecoration(
                                color: MyColors.background,
                                borderRadius:
                                const BorderRadius.all(
                                    Radius.circular(15)),
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 8.0,
                                      color: MyColors
                                          .shadowColor
                                          .withAlpha(25),
                                      offset:
                                      const Offset(0, 3)),
                                ]),
                            child: TextFormField(
                              obscureText: false,
                              keyboardType: TextInputType.number,
                              style: MyComponents.myTextStyle(
                                  Get.textTheme.bodyText1,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.2),
                              decoration: InputDecoration(
                                hintStyle:
                                MyComponents.myTextStyle(
                                    Get.textTheme.bodyText1,
                                    fontWeight:
                                    FontWeight.w500,
                                    letterSpacing: 0,
                                    color: MyColors
                                        .blackColor
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
                              controller: sendAmountController,
                              onChanged: (value) {
                                sendAmount = value;
                              },
                            ),
                          ),
                          Container(
                            height: 40,
                            margin: const EdgeInsets.only(
                                left: 15,
                                right: 15,
                                top: 15),
                            decoration: BoxDecoration(
                              borderRadius:
                              const BorderRadius.all(
                                  Radius.circular(48)),
                              boxShadow: [
                                BoxShadow(
                                  color: MyColors.primary
                                      .withAlpha(80),
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
                                sendStoreMyBalanceTransfer()
                                    .then((value) {
                                  sendAmountController.text =
                                  '';
                                });
                                //print("object $selectReceiverId, $sendAmount");
                              },
                              child: Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.center,
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Balance Send",
                                      style: MyComponents
                                          .myTextStyle(
                                          Get.textTheme
                                              .bodyText2,
                                          color: MyColors
                                              .onPrimary,
                                          letterSpacing:
                                          0.8,
                                          fontWeight:
                                          FontWeight
                                              .w500),
                                    ),
                                  ),
                                  Positioned(
                                    right: 16,
                                    child: ClipOval(
                                      child: Container(
                                        color: MyColors
                                            .primaryVariant,
                                        // button color
                                        child: SizedBox(
                                            width: 25,
                                            height: 25,
                                            child: Icon(
                                              MdiIcons
                                                  .arrowRight,
                                              color: MyColors
                                                  .onPrimary,
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
      body:myBalanceTransferList.isEmpty?const Center(child: const Text('No balance transfer has taken place yet'),): ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: myBalanceTransferList.length,
          itemBuilder: (_, index) {
            date = myBalanceTransferList[index]['date'];
            invoiceNo = myBalanceTransferList[index]['invoice_no'];
            receiverId = myBalanceTransferList[index]['receiver_id']
                .toString();
            amount = myBalanceTransferList[index]['amount'];

            for (int i = 0; i < receiverList.length; i++) {
              if (receiverId == receiverList[i]['id'].toString()) {
                transferTo = receiverList[i]['username'];
              }
            }

            return Slidable(
              actionPane: const SlidableDrawerActionPane(),
              secondaryActions: [
                IconSlideAction(
                  iconWidget: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
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
                    child: const Icon(
                      FontAwesomeIcons.solidTrashAlt,
                      color: Colors.white,
                    ),
                  ),
                  color: Colors.transparent,
                  onTap: () async {
                    //for delete
                    var url =
                    Uri.parse(MyApi.myBalanceTransferDelete);
                    var response = await http.post(url, headers: {
                      "Accept": "application/json",
                      HttpHeaders.authorizationHeader:
                      'Bearer ${controller.token}',
                    }, body: {
                      'transfer_id': myBalanceTransferList[index]
                      ['id']
                          .toString()
                    });

                    switch (json.decode(response.body)['status']) {
                      case 1:
                        {
                          //for remove to ui
                          setState(() {
                            myBalanceTransferList.removeAt(index);
                          });

                          //print(json.decode(response.body)['message']);
                          Get.snackbar(
                              json.decode(response.body)['message'],
                              "Delete form My Balance transfer list");
                        }
                        break;
                      default:
                        {
                          //print(json.decode(response.body)['message']);
                          Get.snackbar(
                              json.decode(response.body)['message'],
                              "Something wrong");
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(FontAwesomeIcons.share,
                                size: 15, color: Colors.red),
                            Text(
                              transferTo,
                              style: MyComponents.myTextStyle(
                                  Get.textTheme.titleMedium,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        Text(
                          invoiceNo,
                          style: MyComponents.myTextStyle(
                            Get.textTheme.caption,
                          ),
                        ),
                        Text(
                          date,
                          style: MyComponents.myTextStyle(
                            Get.textTheme.caption,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      amount,
                      style: MyComponents.myTextStyle(
                          Get.textTheme.titleMedium,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            );
          }),
    ):noInternetConnection();
  }
}
