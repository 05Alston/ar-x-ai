import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_ar/tts.dart';
import 'package:flutter_app_ar/arScreen.dart';
import 'package:flutter_app_ar/stt.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:fluttericon/linearicons_free_icons.dart';
import 'package:fluttericon/linecons_icons.dart';


class NavBar extends StatefulWidget {
@override
_NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  var _currentindex = 1;
  // final ValueNotifier<double> playerExpandProgress = ValueNotifier(70);
  // final height = 70.0;
  final tabs = [
    ArScreen(),
    SpeechToText(),
    TextToSpeech(),
  ];

  // void initState() {
  //   // TODO: implement initState
  //   initGetSong();
  //   super.initState();
  // }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      tabs[_currentindex],
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: _currentindex,
        onTap: (index) {
          setState(() {
            _currentindex = index;
          });
        },
        backgroundColor: Color(0xff1c252a),
        scaleFactor: 0.1,
        unSelectedColor: Colors.grey[500],
        items: [
          CustomNavigationBarItem(
            selectedTitle: Text(
              "AR Camera",
              style: TextStyle(color: Colors.grey[500]),
            ),
            icon: Icon(Entypo.camera),
          ),
          CustomNavigationBarItem(
            selectedTitle: Text(
              "Speech To Text",
              style: TextStyle(color: Colors.grey[500]),
            ),
            icon: Icon(Entypo.mic),
          ),
          CustomNavigationBarItem(
            selectedTitle: Text(
              "Text To Speech",
              style: TextStyle(color: Colors.grey[500]),
            ),
            icon: Icon(Entypo.keyboard),
          ),
        ],
      ),
    );
  }

}