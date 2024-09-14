import 'package:get/get.dart';
import 'package:neuro_task_mosaic/view_models/auth/login_view_model.dart';
import 'package:neuro_task_mosaic/view_models/auth/sign_up_view_model.dart';

class InitDependency{

  static Future<void> injectDependency()async{

    LoginViewModel loginViewModel = Get.put(LoginViewModel());
    SignUpViewModel signUpViewModel = Get.put(SignUpViewModel());

  }
}