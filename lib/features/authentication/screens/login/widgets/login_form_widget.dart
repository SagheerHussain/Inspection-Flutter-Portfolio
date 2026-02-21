import 'package:cwt_starter_template/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import '../../../../../../personalization/controllers/environment_controller.dart';
import '../../../../../../utils/constants/colors.dart';

import '../../../../../../common/widgets/buttons/primary_button.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../../../../../../utils/constants/text_strings.dart';
import '../../../controllers/login_controller.dart';

class LoginFormWidget extends StatelessWidget {
  const LoginFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
    final envController = Get.find<EnvironmentController>();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: TSizes.xl),
      child: Form(
        key: controller.loginFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// -- Username Field
            TextFormField(
              validator:
                  (value) => TValidator.validateEmptyText('Username', value),
              controller: controller.userName,
              decoration: const InputDecoration(
                prefixIcon: Icon(LineAwesomeIcons.user),
                labelText: 'Username',
                hintText: 'Enter your username',
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),

            /// -- Password Field
            Obx(
              () => TextFormField(
                obscureText: controller.hidePassword.value,
                controller: controller.password,
                validator:
                    (value) => TValidator.validateEmptyText('Password', value),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.fingerprint),
                  labelText: TTexts.tPassword,
                  hintText: TTexts.tPassword,
                  suffixIcon: IconButton(
                    onPressed:
                        () =>
                            controller.hidePassword.value =
                                !controller.hidePassword.value,
                    icon: Icon(
                      controller.hidePassword.value
                          ? Iconsax.eye_slash
                          : Iconsax.eye,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),

            /// -- Phone Number Field
            TextFormField(
              validator:
                  (value) =>
                      TValidator.validateEmptyText('Phone Number', value),
              controller: controller.phoneNumber,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.phone_outlined),
                labelText: 'Phone Number',
                hintText: 'Enter your phone number',
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),

            /// -- Environment Toggle (Prod/Dev)
            Obx(
              () => Container(
                margin: const EdgeInsets.only(bottom: TSizes.spaceBtwSections),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color:
                      envController.isProduction
                          ? TColors.success.withValues(alpha: 0.1)
                          : TColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        envController.isProduction
                            ? TColors.success.withValues(alpha: 0.3)
                            : TColors.info.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          envController.isProduction
                              ? Iconsax.shield_tick
                              : Iconsax.setting,
                          color:
                              envController.isProduction
                                  ? TColors.success
                                  : TColors.info,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          envController.isProduction
                              ? "Production Mode"
                              : "Development Mode",
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color:
                                envController.isProduction
                                    ? TColors.success
                                    : TColors.info,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: envController.isProduction,
                      onChanged: (value) => envController.toggleEnvironment(),
                      activeColor: TColors.success,
                      activeTrackColor: TColors.success.withValues(alpha: 0.4),
                      inactiveThumbColor: TColors.info,
                      inactiveTrackColor: TColors.info.withValues(alpha: 0.4),
                    ),
                  ],
                ),
              ),
            ),

            /// -- LOGIN BTN
            Obx(
              () => TPrimaryButton(
                isLoading: controller.isLoading.value,
                text: TTexts.tLogin.tr,
                onPressed:
                    controller.isLoading.value
                        ? () {}
                        : () => controller.login(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
