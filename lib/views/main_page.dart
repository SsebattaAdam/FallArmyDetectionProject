
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';


import '../constants/constants.dart';
import '../controllers/tab_index_controller.dart';

import 'community/community.dart';
import 'home/newpage.dart';
import 'home/homepagedef.dart';
import 'map/fallarmywormdisplaymap.dart';

class main_page extends StatelessWidget {
   main_page({super.key});

   List<Widget>  pages = const [
     Homepage2Default(),

     CommunityPage(),
     Newpagetobedefined()
   ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TabIndexController());
    return Obx(() => Scaffold(
      body:  Stack(
        children: [
       pages[controller.tabIndex],
          Align(
            alignment:  Alignment.bottomCenter,
            child: Theme(data: Theme.of(context).copyWith(canvasColor: kPrimary),
                child: BottomNavigationBar(
                    showSelectedLabels: true,
                    showUnselectedLabels: true,
                    unselectedIconTheme: const IconThemeData(color: Colors.black38),
                    selectedIconTheme: const IconThemeData(color: kPrimaryLight),
                    onTap: (index) {
                      controller.setTabIndex(index);
                    },
                    currentIndex: controller.tabIndex,
                    items:  [
                      BottomNavigationBarItem(
                        icon: controller.tabIndex ==0?  Icon(AntDesign.appstore1): Icon(AntDesign.appstore_o),
                        label: 'Home',
                      ),

                      const BottomNavigationBarItem(
                        icon: Badge(
                          label: Text('1', style: TextStyle(color: kOffWhite),),
                            child: Icon(FontAwesome.group)),
                        label: 'Community',
                      ),
                      BottomNavigationBarItem(

                        icon:  controller.tabIndex == 2 ? Icon(FontAwesome.map): Icon(FontAwesome.map_o),
                        label: 'coverage',
                      ),
                    ]
                )
            ),
          )
        ],
      ),
    ));
  }
}
