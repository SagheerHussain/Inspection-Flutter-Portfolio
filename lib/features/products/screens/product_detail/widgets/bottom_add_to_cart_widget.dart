import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../controllers/product_controller.dart';
import '../../../models/product_model.dart';

class TBottomAddToCart extends StatelessWidget {
  const TBottomAddToCart({
    super.key,
    required this.product,
  });

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final productController = ProductController.instance;
    productController.initializeAlreadyAddedProductCount(product);
    final dark = THelperFunctions.isDarkMode(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace, vertical: TSizes.defaultSpace / 2),
      decoration: BoxDecoration(
        color: dark ? TColors.darkerGrey : TColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(TSizes.cardRadiusLg),
          topRight: Radius.circular(TSizes.cardRadiusLg),
        ),
      ),
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Quantity controls
            Row(
              children: [
                IconButton(
                  onPressed: () => productController.cartQuantity.value < 1
                      ? null
                      : productController.cartQuantity.value -= 1,
                  icon: const Icon(Iconsax.minus, color: TColors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: TColors.darkGrey,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TSizes.sm)),
                  ),
                ),
                const SizedBox(width: TSizes.spaceBtwItems),
                Text(productController.cartQuantity.value.toString(),
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(width: TSizes.spaceBtwItems),
                IconButton(
                  onPressed: () => productController.cartQuantity.value += 1,
                  icon: const Icon(Iconsax.add, color: TColors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: TColors.dashboardAppbarBackground,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TSizes.sm)),
                  ),
                ),
              ],
            ),
            // Add to cart button
            ElevatedButton(
              onPressed:
                  productController.cartQuantity.value < 1 ? null : () => productController.addProductToCart(product),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(TSizes.md),
                backgroundColor: TColors.black,
                side: const BorderSide(color: TColors.black),
              ),
              child: const Row(
                children: [Icon(Iconsax.shopping_bag), SizedBox(width: TSizes.spaceBtwItems / 2), Text('Add to Bag')],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
