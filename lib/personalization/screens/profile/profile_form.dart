import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import '../../../../../personalization/controllers/user_controller.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/text_strings.dart';

class ProfileFormScreen extends StatelessWidget {
  const ProfileFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;

    return Column(
      children: [
        TextFormField(
          controller: controller.username,
          enabled: false,
          decoration: const InputDecoration(
            label: Text("Username"),
            prefixIcon: Icon(LineAwesomeIcons.user),
          ),
        ),
        const SizedBox(height: TSizes.xl - 20),
        TextFormField(
          controller: controller.phoneNo,
          enabled: false,
          decoration: const InputDecoration(
            label: Text(TTexts.tPhoneNo),
            prefixIcon: Icon(LineAwesomeIcons.phone_solid),
          ),
        ),
      ],
    );
  }
}
