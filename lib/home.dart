import 'package:century5/config/my_colors.dart';
import 'package:century5/views/balance_withdraw/balance_withdraw.dart';
import 'package:century5/views/dashboard/dashboard_screen.dart';
import 'package:century5/views/fund_transfer/fund_transfer_list.dart';
import 'package:century5/views/wallet_transfer/wallet_transfer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';


class Send extends StatelessWidget {
  const Send({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("data"),
      ),
    );
  }
}
class Transfer extends StatelessWidget {
  const Transfer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("data"),
      ),
    );
  }
}



class Body extends StatefulWidget {

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  int _currentTabIndex = 0;
  var count = 0;

  Future<bool> backPressed(GlobalKey<NavigatorState> _yourKey) async {
    if (_yourKey.currentState!.canPop()) {

      if(_yourKey.currentState == DashboardScreen()){
        return Future<bool>.value(true);
      }
      _yourKey.currentState!.maybePop();
      return Future<bool>.value(false);
    }
    return Future<bool>.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () => backPressed(_navigatorKey),
        child: Scaffold(
          body: Navigator(key: _navigatorKey, onGenerateRoute: generateRoute),
          //bottomNavigationBar: _bottomNavigationBar(),
          bottomNavigationBar: CupertinoTabBar(
            border: const Border(top: BorderSide.none),
            currentIndex: _currentTabIndex,
            onTap: _onTap,
            activeColor: MyColors.primary,
            inactiveColor: Colors.grey,
            backgroundColor: Colors.white,
            items: const [
              BottomNavigationBarItem(icon: Icon(MdiIcons.home,size: 25,),label: 'Home'),
              BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.creditCard,size: 20,),label: 'Withdraw'),
              BottomNavigationBarItem(icon: Icon(MdiIcons.transfer,size: 25,),label: 'Transfer'),
              BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.wallet,size: 20,),label: 'Wallet'),
            ],
        ),
        ),
      ),
    );
  }


  _onTap(int tabIndex) {
    switch (tabIndex) {
      case 0:
        _navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) => DashboardScreen()));
        break;
      case 1:
        _navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) => const BalanceWithdrawScreen()));
        break;
      case 2:
        _navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) => const FundTransferListScreen()));
        break;
      case 3:
        _navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) => const WalletTransferScreen()));
        break;
    }
    setState(() {
      _currentTabIndex = tabIndex;
    });
  }

  Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case "Home":
        return MaterialPageRoute(builder: (BuildContext context) => DashboardScreen());
      case "Withdraw":
        return MaterialPageRoute(builder: (BuildContext context) => const BalanceWithdrawScreen());
      case "Transfer":
        return MaterialPageRoute(builder: (BuildContext context) => const FundTransferListScreen());
      case "Wallet":
        return MaterialPageRoute(builder: (BuildContext context) => const WalletTransferScreen());
      default:
        return MaterialPageRoute(builder: (BuildContext context) => DashboardScreen());
    }
  }
}


