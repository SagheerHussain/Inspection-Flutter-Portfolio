import 'package:flutter/material.dart';
import '../../../../../common/widgets/form/form_header_widget.dart';
import '../../../../../utils/constants/image_strings.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/text_strings.dart';
import 'widgets/login_form_widget.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(TSizes.defaultSpace),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FormHeaderWidget(
                  image: TImages.tWelcomeScreenImage,
                  title: TTexts.tLoginTitle,
                  subTitle: TTexts.tLoginSubTitle,
                ),
                const LoginFormWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
