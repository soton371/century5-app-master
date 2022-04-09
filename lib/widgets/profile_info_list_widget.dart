import 'package:century5/config/my_colors.dart';
import 'package:century5/config/my_components.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class ProfileInfoListWidget extends StatelessWidget {
  //const ProfileInfoListWidget({Key? key}) : super(key: key);

  IconData myIcon = FontAwesomeIcons.font;
  String myTitle = 'Title';
  String myInfo = 'Info';


  ProfileInfoListWidget(this.myIcon, this.myTitle, this.myInfo);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
              color: MyColors.background,
              borderRadius: const BorderRadius.all(Radius.circular(50)),
              boxShadow: [
                BoxShadow(
                    blurRadius: 8.0,
                    color: MyColors.shadowColor.withAlpha(25),
                    offset: const Offset(0, 3)),
              ]),
          child: Icon(myIcon,color: MyColors.primary.withOpacity(0.7),size: 20,),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("    $myTitle",
                style: MyComponents.myTextStyle(
                  Get.textTheme.caption,
                ),
            ),
            Text("   $myInfo",
                style: MyComponents.myTextStyle(
                  Get.textTheme.titleMedium,
                  fontWeight: FontWeight.w500
                )
            )
          ],
        )
      ],
    );
  }
}

