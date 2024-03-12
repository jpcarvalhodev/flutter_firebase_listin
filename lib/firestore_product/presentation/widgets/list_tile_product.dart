import 'package:flutter/material.dart';
import '../../models/product.dart';

class ListTileProduct extends StatelessWidget {
  final String listinId;
  final Product product;
  final bool isBought;
  final Function showModal;
  final Function iconClick;
  final Function deleteClick;
  const ListTileProduct({
    super.key,
    required this.listinId,
    required this.product,
    required this.isBought,
    required this.showModal,
    required this.iconClick,
    required this.deleteClick,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        showModal(model: product);
      },
      leading: IconButton(
        onPressed: () {
          iconClick(product: product, listinId: listinId);
        },
        icon: Icon(
          (isBought) ? Icons.shopping_basket : Icons.check,
        ),
      ),
      trailing: IconButton(
        onPressed: () {
          deleteClick(product);
        },
        icon: const Icon(Icons.delete, color: Colors.red),
      ),
      title: Text(
        (product.amount == null)
            ? product.name
            : "${product.name} (x${product.amount!.toInt()})",
      ),
      subtitle: Text(
        (product.price == null) ? "Click to add price" : "\$ ${product.price!}",
      ),
    );
  }
}
