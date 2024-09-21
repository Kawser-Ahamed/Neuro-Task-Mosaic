import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neuro_task_mosaic/view/home/pages/homepage.dart';
import 'package:neuro_task_mosaic/view/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpViewModel extends GetxController{

   RxBool isLoading = false.obs;

  Future<void> signUpWithFirebase(BuildContext context, email,String password,String fullName,String birthDate,String activity) async{
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    DateTime currentTime = DateTime.now();
    int id = currentTime.microsecondsSinceEpoch;
    if(email.isEmpty || password.isEmpty  || fullName.isEmpty  || birthDate.isEmpty  || activity.isEmpty){
      Get.snackbar('Neuro Task', 'Please fill all the input box');
    }
    else if(password.length<8){
      Get.snackbar('Neuro Task', "Weak Password");
    }
    else{
      isLoading.value = true;
      try{
        // ignore: unused_local_variable
        UserCredential user = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: password
        );
        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
        //user.user!.sendEmailVerification();

        FirebaseFirestore.instance.collection(email).doc(id.toString()).set({
          'Patient Id' : id.toString(),
          'Full Name' : fullName,
          'Patient Email' : email,
          'Date Of Birth (DD-MM-YYYY)' : birthDate,
          'Activity' : activity,
        }).then((value){
          sharedPreferences.setString('email', email);
          patientemail = email;
          Get.snackbar('Neuro Task', 'Your Account Creation Successfull');
          navigator!.pop(context);
          Get.offAll(const HomePage());
        });
      }on FirebaseAuthException catch(e){
        if(e.code == 'weak-password'){
          Get.snackbar('Weak Password', 'Your Password Is Weak');
        }
        else if(e.code == 'email-already-in-use'){
          Get.snackbar('Reused Email', 'Your Email Is Already Used',
          );
        }
      } catch (error) {
        Get.snackbar('Error', 'FoodFrenzy Server is Down');
      }finally{
        // ignore: use_build_context_synchronously
        navigator!.pop(context);
        isLoading.value = false;
      }
    }
    // ignore: use_build_context_synchronously
    navigator!.pop(context);
  }

}