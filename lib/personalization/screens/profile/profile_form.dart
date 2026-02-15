import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/text_strings.dart';

class ProfileFormScreen extends StatelessWidget {
  const ProfileFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          initialValue: 'Inspection Engineer',
          enabled: false,
          decoration: const InputDecoration(
            label: Text(TTexts.tFullName),
            prefixIcon: Icon(LineAwesomeIcons.user),
          ),
        ),
        const SizedBox(height: TSizes.xl - 20),
        TextFormField(
          initialValue: 'sagheer@gmail.com',
          enabled: false,
          decoration: const InputDecoration(
            label: Text(TTexts.tEmail),
            prefixIcon: Icon(LineAwesomeIcons.envelope),
          ),
        ),
        const SizedBox(height: TSizes.xl - 20),
        TextFormField(
          initialValue: '03313908443',
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
