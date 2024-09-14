import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:neuro_task_mosaic/view/home/pages/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginViewModel extends GetxController{
  RxBool isLoading = false.obs;
  Future<void> firebaseLogin(String email,String password) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final auth = FirebaseAuth.instance;
    if(email.isEmpty || password.isEmpty){
      Get.snackbar('Neuro Task', 'Please fill all information');
    }
    else{
      isLoading.value = true;
      try{
        await auth.signInWithEmailAndPassword(
            email: email,
            password: password
        );
        sharedPreferences.setString('email', email);
        //patientemail = email;
        Get.offAll(const HomePage());
      } on FirebaseAuthException catch(e){
        //print('FirebaseAuthException: ${e.code}');
        if(e.code == 'user-not-found'){
          Get.snackbar('Neuro Task', 'Your Email Is Incorrect');
        }
        else if(e.code == 'wrong-password'){
          Get.snackbar('Neuro Task', 'Your Password Is Wrong');
        }
        else{
          Get.snackbar('Neuro Task', 'Your Email Or Password Is Wrong');
        }
      } catch(e){
        Get.snackbar('Neuro Task', '$e');
      }finally{
        isLoading.value = false;
      }
    }
  }

}