//import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neuro_task_mosaic/resource/screen/responsive.dart';
import 'package:neuro_task_mosaic/view/auth/pages/sign_in.dart';
import 'package:neuro_task_mosaic/view/grand_father_passage/pages/grandfather_passage.dart';
import 'package:neuro_task_mosaic/view/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: prefer_typing_uninitialized_variables
var patientId;
// ignore: prefer_typing_uninitialized_variables
var email;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // ignore: prefer_typing_uninitialized_variables
  double screenHeight = 0.0;
  double screenWidth = 0.0;
  @override
  Widget build(BuildContext context) {
    double height = Responsive.screenHeight(context);
    double width = Responsive.screenWidth(context);
    screenHeight = height;
    screenWidth= width;
    return SafeArea(
      child: Scaffold(
        body: Container(
          height: height * 1,
          width: width * 1,
          color: Colors.white,
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection(patientemail).snapshots(),
            builder: (context, snapshot) {
              if(snapshot.connectionState == ConnectionState.waiting){
                return const Center(child: CircularProgressIndicator());
              }
              else if(snapshot.hasData){
                List<dynamic> patientList = snapshot.data!.docs.map((e) => e.data()).toList();
                return ListView.builder(
                  itemCount: patientList.length,
                  itemBuilder: (context, index) {
                    Map<dynamic,dynamic> patientMap = patientList[index] as Map<dynamic,dynamic>;
                    patientId = patientMap['Patient Id'];
                    return Container(
                        height: height * 1,
                        width: width * 1,
                        color: Colors.transparent,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Text(patientemail),
                              GestureDetector(
                                onTap: (){
                                  Get.to(const GrandFatherPassage());
                                },
                                child: customCard("Grandfather Passage","Read the passage shown aloud.","assets/images/grandfather.jpg"),
                              ),
                              SizedBox(height: height * 0.05),
                              TextButton(
                                onPressed: () async{
                                  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                                  sharedPreferences.remove('email');
                                  Get.to(const Login());
                                },
                                child: const Text('Logout'),
                              ),
                              SizedBox(height: height * 0.05),
                            ],
                          ),
                        )
                    );
                  },
                );
              }
              else{
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
    );
  }

  customCard(String str,String str2,String path){
    return  Padding(
      padding: EdgeInsets.only(left:((screenWidth/Responsive.designWidth) * 10),right: ((screenWidth/Responsive.designWidth) * 10)),
      child: Card(
        color: Colors.white,
        child: ListTile(
          leading: Container(
            height: screenHeight * 0.2,
            width: screenWidth * 0.15,
            decoration: BoxDecoration(
              color: Colors.transparent,
              image: DecorationImage(
                image: AssetImage(path),
                fit: BoxFit.contain,
              ),
            ),
          ),
          title: Text(str),
          subtitle: Text(str2),
        ),
      ),
    );
  }
}