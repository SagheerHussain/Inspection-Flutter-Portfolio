import 'package:flutter/material.dart';

import '../../../../../../utils/constants/image_strings.dart';

class ImageWithIcon extends StatelessWidget {
  const ImageWithIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: const Image(image: AssetImage(TImages.tProfileImage)),
      ),
    );
  }
}
