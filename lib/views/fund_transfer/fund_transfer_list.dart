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
import 'package:intl/intl.dart';

class FundTransferListScreen extends StatefulWidget {
  const FundTransferListScreen({Key? key}) : super(key: key);

  @override
  _FundTransferListScreenState createState() => _FundTransferListScreenState();
}

class _FundTransferListScreenState extends State<FundTransferListScreen> {
  double xOffset = 0;
  double yOffset = 0;
  double scaleFactor = 1;
  bool isDrawerOpen = false;

  var controller = Get.put(AuthController());
  List history = [];
  var transfer, date, invoice, amount, approved;

  //for fund transfer data
  var availableBalance, remarks, selectReceiver;
  List receiverList = [];
  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String userId = '';
  String transferAmount = '';
  String transferRemarks = '';

  var transferAmountController = TextEditingController();
  var transferRemarkController = TextEditingController();

  //for fund transfer request
  var selectSender;
  List senderList = [];
  String reqUserId = '';
  String requestAmount = '';
  String requestRemark = '';

  var requestAmountController = TextEditingController();
  var requestRemarkController = TextEditingController();

  //for name
  String receiverName = 'admin@gmail.com';
  var receiverId;

  //for delete
  String deleteId = '';

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
    fetchFundTransferList();
    fetchFundTransferCreateData();
    fetchFundTransferRequestCreateData();
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

//for list
  Future fetchFundTransferList() async {
    var url = Uri.parse(MyApi.getFundTransferList);
    var response = await http.post(url, headers: {
      "Accept": "application/json",
      HttpHeaders.authorizationHeader: 'Bearer ${controller.token}',
    });

    switch (json.decode(response.body)['status']) {
      case 1:
        {
          setState(() {
            history = json.decode(response.body)['data']['data'];
          });
        }
        break;
      default:
        {
          //print(json.decode(response.body)['message']);
          Get.snackbar(
              json.decode(response.body)['message'], "something wrong",colorText: Colors.red);
        }
        break;
    }
  }

//for fund transfer
  Future fetchFundTransferCreateData() async {
    var url = Uri.parse(MyApi.getFundTransferCreateData);
    var response = await http.post(url, headers: {
      "Accept": "application/json",
      HttpHeaders.authorizationHeader: 'Bearer ${controller.token}',
    });

    switch (json.decode(response.body)['status']) {
      case 1:
        {
          setState(() {
            receiverList = json.decode(response.body)['data']['users'];
            availableBalance =
                json.decode(response.body)['data']['availableBalance'];
          });
        }
        break;
      default:
        {
          //print(json.decode(response.body)['message']);
          Get.snackbar(
              json.decode(response.body)['message'], "something wrong",colorText: Colors.red);
        }
        break;
    }
  }

  //store fund transfer
  Future sendStoreFundTransfer() async {
    for (int i = 0; i < receiverList.length; i++) {
      if (receiverList[i]['username'] == selectReceiver) {
        setState(() {
          userId = receiverList[i]['id'].toString();
        });
      }
    }

    if (int.parse(transferAmount) > 99) {
      var url = Uri.parse(MyApi.storeFundTransfer);
      var response = await http.post(url, headers: {
        "Accept": "application/json",
        HttpHeaders.authorizationHeader: 'Bearer ${controller.token}',
      }, body: {
        'user_id': userId,
        'date': formattedDate,
        'amount': transferAmount,
        'remarks': transferRemarks
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
                    const FundTransferListScreen()));
            Get.snackbar(
                'Thanks', "Your balance transfer has been sent successfully");
          }
          break;
        default:
          {
            //print(json.decode(response.body)['message']);
            Get.snackbar(
                json.decode(response.body)['message'], "Something wrong",
                colorText: Colors.red);
          }
          break;
      }
    } else {
      Get.snackbar('Please', 'Amount must be greater than 99',
          colorText: Colors.red);
    }
  }

  //fetch fund transfer request
  Future fetchFundTransferRequestCreateData() async {
    var url = Uri.parse(MyApi.getFundTransferRequestCreateData);
    var response = await http.post(url, headers: {
      "Accept": "application/json",
      HttpHeaders.authorizationHeader: 'Bearer ${controller.token}',
    });

    switch (json.decode(response.body)['status']) {
      case 1:
        {
          setState(() {
            senderList = json.decode(response.body)['data']['users'];
          });
        }
        break;
      default:
        {
          //print(json.decode(response.body)['message']);
          Get.snackbar(
              json.decode(response.body)['message'], "something wrong",colorText: Colors.red);
        }
        break;
    }
  }

  //store fund transfer request
  Future sendStoreFundTransferRequest() async {
    for (int i = 0; i < senderList.length; i++) {
      if (senderList[i]['username'] == selectSender) {
        setState(() {
          reqUserId = senderList[i]['id'].toString();
        });
      }
    }

    if (int.parse(requestAmount) > 99) {
      var url = Uri.parse(MyApi.storeFundTransferRequest);
      var response = await http.post(url, headers: {
        "Accept": "application/json",
        HttpHeaders.authorizationHeader: 'Bearer ${controller.token}',
      }, body: {
        'user_id': reqUserId,
        'date': formattedDate,
        'amount': requestAmount,
        'transfer_type': 'request',
        'remarks': requestRemark
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
                    const FundTransferListScreen()));
            Get.snackbar('Thanks', "Your request has been sent successfully");
          }
          break;
        default:
          {
            //print(json.decode(response.body)['message']);
            Get.snackbar(
                json.decode(response.body)['message'], "Something wrong",
                colorText: Colors.red);
          }
          break;
      }
    } else {
      Get.snackbar('Please', 'Amount must be greater than 99',
          colorText: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return status? Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.fullAABackground,
        elevation: 0,
        titleSpacing: 0,
        title: Text(
          "Transfer List",
          style: MyComponents.myTextStyle(
            Get.textTheme.headline6,
          ),
        ),
        actions: [
          //for send request
          IconButton(
              onPressed: () => Get.defaultDialog(
                      title: 'Transfer Request',
                      content: SingleChildScrollView(
                        child: Column(
                          children: [
                            //select wallet
                            Container(
                              margin: const EdgeInsets.only(bottom: 15),
                              decoration: BoxDecoration(
                                  color: MyColors.background,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(15)),
                                  boxShadow: [
                                    BoxShadow(
                                        blurRadius: 8.0,
                                        color:
                                            MyColors.shadowColor.withAlpha(25),
                                        offset: const Offset(0, 3)),
                                  ]),
                              child: DropdownSearch<String>(
                                dropdownSearchBaseStyle:
                                    MyComponents.myTextStyle(
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
                                      color:
                                          MyColors.blackColor.withAlpha(100)),
                                  hintText: "-Select Sender-",
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.all(15),
                                ),
                                items: [
                                  for (int i = 0;
                                      i < senderList.length;
                                      i++) ...{senderList[i]['username']}
                                ],
                                onChanged: (v) => selectSender = v,
                              ),
                            ),
                            //for amount
                            Container(
                              margin: const EdgeInsets.only(bottom: 15),
                              decoration: BoxDecoration(
                                  color: MyColors.background,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(15)),
                                  boxShadow: [
                                    BoxShadow(
                                        blurRadius: 8.0,
                                        color:
                                            MyColors.shadowColor.withAlpha(25),
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
                                      color:
                                          MyColors.blackColor.withAlpha(100)),
                                  hintText: "Amount*",
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.all(15),
                                ),
                                autofocus: false,
                                controller: requestAmountController,
                                onChanged: (v) => requestAmount = v,
                              ),
                            ),
                            //for remarks
                            // Container(
                            //   margin: const EdgeInsets.only(bottom: 15),
                            //   decoration: BoxDecoration(
                            //       color: MyColors.background,
                            //       borderRadius: const BorderRadius.all(
                            //           Radius.circular(15)),
                            //       boxShadow: [
                            //         BoxShadow(
                            //             blurRadius: 8.0,
                            //             color:
                            //                 MyColors.shadowColor.withAlpha(25),
                            //             offset: const Offset(0, 3)),
                            //       ]),
                            //   child: TextFormField(
                            //     obscureText: false,
                            //     style: MyComponents.myTextStyle(
                            //         Get.textTheme.bodyText1,
                            //         fontWeight: FontWeight.w500,
                            //         letterSpacing: 0.2),
                            //     decoration: InputDecoration(
                            //       hintStyle: MyComponents.myTextStyle(
                            //           Get.textTheme.bodyText1,
                            //           fontWeight: FontWeight.w500,
                            //           letterSpacing: 0,
                            //           color:
                            //               MyColors.blackColor.withAlpha(100)),
                            //       hintText: "Remarks",
                            //       border: InputBorder.none,
                            //       enabledBorder: InputBorder.none,
                            //       focusedBorder: InputBorder.none,
                            //       isDense: true,
                            //       contentPadding: const EdgeInsets.all(15),
                            //     ),
                            //     autofocus: false,
                            //     controller: requestRemarkController,
                            //     onChanged: (v) => requestRemark = v,
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      actions: [
                        Container(
                          height: 40,
                          margin: const EdgeInsets.only(
                              left: 15, right: 15, bottom: 15),
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(48)),
                            boxShadow: [
                              BoxShadow(
                                color: MyColors.primary.withAlpha(80),
                                blurRadius: 5,
                                offset: const Offset(
                                    0, 5), // changes position of shadow
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: MyColors.primary),
                            onPressed: () async {
                              sendStoreFundTransferRequest().then((value) {
                                requestAmountController.text='';
                              });
                            },
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Send Request",
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
                      ]),
              icon: Icon(
                FontAwesomeIcons.paperPlane,
                color: MyColors.secondaryVariant,
                size: 18,
              )),
          //for fund transfer
          IconButton(
              onPressed: () => Get.defaultDialog(
                      title: 'Available ৳${availableBalance.toString()}',

                      content: double.parse(availableBalance.toString()) <= 0
                          ? Text(
                              "Sorry! You do not have the available balance to transfer. You can get the balance from the top level of admin or sponsor",
                              style: MyComponents.myTextStyle(
                                Get.textTheme.titleMedium,
                              ),
                              textAlign: TextAlign.center,
                            )
                          : SingleChildScrollView(
                              child: Column(
                                children: [
                                  //select receiver
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 15),
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
                                    child: DropdownSearch<String>(
                                      dropdownSearchBaseStyle:
                                          MyComponents.myTextStyle(
                                              Get.textTheme.bodyText1,
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: 0.2),
                                      popupShape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      mode: Mode.MENU,
                                      showSearchBox: true,
                                      showAsSuffixIcons: true,
                                      dropdownSearchDecoration: InputDecoration(
                                        hintStyle: MyComponents.myTextStyle(
                                            Get.textTheme.bodyText1,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0,
                                            color: MyColors.blackColor
                                                .withAlpha(100)),
                                        hintText: "-Select Receiver-",
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
                                          receiverList[i]['username'],
                                        }
                                      ],
                                      onChanged: (v) => selectReceiver = v!,
                                    ),
                                  ),
                                  //for amount
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 15),
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
                                      controller: transferAmountController,
                                      onChanged: (value) {
                                        transferAmount = value;
                                      },
                                    ),
                                  ),
                                  //for remarks
                                  // Container(
                                  //   margin: const EdgeInsets.only(bottom: 15),
                                  //   decoration: BoxDecoration(
                                  //       color: MyColors.background,
                                  //       borderRadius: const BorderRadius.all(
                                  //           Radius.circular(15)),
                                  //       boxShadow: [
                                  //         BoxShadow(
                                  //             blurRadius: 8.0,
                                  //             color: MyColors.shadowColor
                                  //                 .withAlpha(25),
                                  //             offset: const Offset(0, 3)),
                                  //       ]),
                                  //   child: TextFormField(
                                  //     obscureText: false,
                                  //     style: MyComponents.myTextStyle(
                                  //         Get.textTheme.bodyText1,
                                  //         fontWeight: FontWeight.w500,
                                  //         letterSpacing: 0.2),
                                  //     decoration: InputDecoration(
                                  //       hintStyle: MyComponents.myTextStyle(
                                  //           Get.textTheme.bodyText1,
                                  //           fontWeight: FontWeight.w500,
                                  //           letterSpacing: 0,
                                  //           color: MyColors.blackColor
                                  //               .withAlpha(100)),
                                  //       hintText: "Remarks",
                                  //       border: InputBorder.none,
                                  //       enabledBorder: InputBorder.none,
                                  //       focusedBorder: InputBorder.none,
                                  //       isDense: true,
                                  //       contentPadding:
                                  //           const EdgeInsets.all(15),
                                  //     ),
                                  //     autofocus: false,
                                  //     controller: transferRemarkController,
                                  //     onChanged: (value) {
                                  //       transferRemarks = value;
                                  //     },
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                      actions: [
                        int.parse(availableBalance.toString()) <= 0
                            ? const SizedBox()
                            :
                        Container(
                          height: 40,
                          margin: const EdgeInsets.only(
                              left: 15, right: 15, bottom: 15),
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(48)),
                            boxShadow: [
                              BoxShadow(
                                color: MyColors.primary.withAlpha(80),
                                blurRadius: 5,
                                offset: const Offset(
                                    0, 5), // changes position of shadow
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: MyColors.primary),
                            onPressed: () async {
                              sendStoreFundTransfer().then((value) {
                                transferAmountController.text = '';
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
                      ]),
              icon: Icon(
                Icons.add,
                color: MyColors.secondaryVariant,
              )),
        ],
      ),
      drawer: const MyDrawerWidget(),
      body: history.isEmpty
          ? const Center(child: Text('No transfer has taken place yet'))
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: history.length,
              itemBuilder: (_, index) {
                date = history[index]['date'];
                invoice = history[index]['invoice_no'];
                amount = history[index]['amount'];
                approved = history[index]['is_approved'];
                //for name
                receiverId = history[index]['receiver_id'];
                for (int i = 0; i < receiverList.length; i++) {
                  var findId = receiverList[i]['id'];
                  if (receiverId == findId) {
                    receiverName = receiverList[i]['username'];
                  }
                }

                return Slidable(
                  actionPane: const SlidableDrawerActionPane(),
                  secondaryActions: [
                    approved == 1
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
                                    Radius.circular(MySizes.size12)),
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
                              var url = Uri.parse(MyApi.fundTransferDelete);
                              var response = await http.post(url, headers: {
                                "Accept": "application/json",
                                HttpHeaders.authorizationHeader:
                                    'Bearer ${controller.token}',
                              }, body: {
                                'fund_transfer_id':
                                    history[index]['id'].toString()
                              });

                              switch (json.decode(response.body)['status']) {
                                case 1:
                                  {
                                    //for remove to ui
                                    setState(() {
                                      history.removeAt(index);
                                    });
                                    //print(json.decode(response.body)['message']);
                                    Get.snackbar(
                                        json.decode(response.body)['message'],
                                        "Delete form transfer list");
                                  }
                                  break;
                                default:
                                  {
                                    //print(json.decode(response.body)['message']);
                                    Get.snackbar(
                                        json.decode(response.body)['message'],
                                        "Something wrong",colorText: Colors.red);
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
                      borderRadius:
                          BorderRadius.all(Radius.circular(MySizes.size15)),
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
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                receiverId.toString() ==
                                        controller.myId.toString()
                                    ? RotatedBox(
                                        quarterTurns: 2,
                                        child: Icon(
                                          FontAwesomeIcons.share,
                                          size: 15,
                                          color: MyColors.secondaryVariant,
                                        ))
                                    : const Icon(
                                        FontAwesomeIcons.share,
                                        size: 15,
                                        color: Colors.red,
                                      ),
                                Text(
                                  " $receiverName",
                                  style: MyComponents.myTextStyle(
                                      Get.textTheme.titleMedium,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            Text(
                              invoice,
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
                        Column(
                          //crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            receiverId.toString() == controller.myId.toString()
                                ? Text(
                                    "+\$$amount",
                                    style: MyComponents.myTextStyle(
                                        Get.textTheme.titleMedium,
                                        fontWeight: FontWeight.w500,
                                        color: MyColors.secondaryVariant),
                                  )
                                : Text(
                                    "-\$$amount",
                                    style: MyComponents.myTextStyle(
                                        Get.textTheme.titleMedium,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.red),
                                  ),
                            GestureDetector(
                              onTap: () async {
                                //for approved
                                var url = Uri.parse(MyApi.fundTransferApprove);
                                var response = await http.post(url, headers: {
                                  "Accept": "application/json",
                                  HttpHeaders.authorizationHeader:
                                      'Bearer ${controller.token}',
                                }, body: {
                                  'fund_transfer_id':
                                      history[index]['id'].toString()
                                });

                                switch (json.decode(response.body)['status']) {
                                  case 1:
                                    {
                                      setState(() {
                                        approved = 1;
                                      });
                                      //print(json.decode(response.body)['message']);
                                      Get.snackbar(
                                          json.decode(response.body)['message'],
                                          "This is approved");
                                    }
                                    break;
                                  default:
                                    {
                                      //print(json.decode(response.body)['message']);
                                      Get.snackbar(
                                          json.decode(response.body)['message'],
                                          "Only user can approved",
                                          colorText: Colors.red);
                                    }
                                    break;
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 3),
                                margin: const EdgeInsets.only(top: 5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: approved == 1
                                      ? MyColors.secondary
                                      : MyColors.rattingColor.withOpacity(0.5),
                                ),
                                child: Text(
                                  approved == 1 ? "Approved" : 'Pending',
                                  style: MyComponents.myTextStyle(
                                      Get.textTheme.button,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white),
                                ),
                              ),
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
