import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_listin/firestore_product/helpers/enum_order.dart';
import 'package:flutter_firebase_listin/firestore_product/services/product_services.dart';
import 'package:uuid/uuid.dart';
import '../../firestore/models/listin.dart';
import '../models/product.dart';
import 'widgets/list_tile_product.dart';

class ProductScreen extends StatefulWidget {
  final Listin listin;
  const ProductScreen({super.key, required this.listin});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<Product> listPlannedProducts = [];
  List<Product> listProductsCaught = [];

  ProductService productService = ProductService();

  OrderProducts order = OrderProducts.name;
  bool isDescendent = false;
  late StreamSubscription listener;

  @override
  void initState() {
    setupListeners();
    super.initState();
  }

  @override
  void dispose() {
    listener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listin.name),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  value: OrderProducts.name,
                  child: Text("Order by name"),
                ),
                const PopupMenuItem(
                  value: OrderProducts.price,
                  child: Text("Order by price"),
                ),
                const PopupMenuItem(
                  value: OrderProducts.amount,
                  child: Text("Order by amount"),
                ),
              ];
            },
            onSelected: (value) {
              setState(() {
                if (order == value) {
                  isDescendent = !isDescendent;
                } else {
                  order = value;
                  isDescendent = false;
                }
              });
              refresh();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showFormModal();
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return refresh();
        },
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                children: [
                  Text(
                    "\$${calculateTotalCaught().toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 42),
                  ),
                  const Text(
                    "Total amount spent",
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Divider(thickness: 2),
            ),
            const Text(
              "Planned Products",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Column(
              children: List.generate(listPlannedProducts.length, (index) {
                Product product = listPlannedProducts[index];
                return ListTileProduct(
                  listinId: widget.listin.id,
                  product: product,
                  isBought: false,
                  showModal: showFormModal,
                  iconClick: productService.changeBoughtStatus,
                  deleteClick: deleteProduct,
                );
              }),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Divider(thickness: 2),
            ),
            const Text(
              "Products Bought",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Column(
              children: List.generate(listProductsCaught.length, (index) {
                Product product = listProductsCaught[index];
                return ListTileProduct(
                  listinId: widget.listin.id,
                  product: product,
                  isBought: true,
                  showModal: showFormModal,
                  iconClick: productService.changeBoughtStatus,
                  deleteClick: deleteProduct,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  showFormModal({Product? model}) {
    String labelTitle = "Add Product";
    String labelConfirmationButton = "Save";
    String labelSkipButton = "Cancel";

    TextEditingController nameController = TextEditingController();
    TextEditingController amountController = TextEditingController();
    TextEditingController priceController = TextEditingController();

    bool isBought = false;

    if (model != null) {
      labelTitle = "Editing ${model.name}";
      nameController.text = model.name;

      if (model.price != null) {
        priceController.text = model.price.toString();
      }

      if (model.amount != null) {
        amountController.text = model.amount.toString();
      }

      isBought = model.isBought;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          padding: const EdgeInsets.all(32.0),
          child: ListView(
            children: [
              Text(labelTitle,
                  style: Theme.of(context).textTheme.headlineSmall),
              TextFormField(
                controller: nameController,
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  label: Text("Name of Product*"),
                  icon: Icon(Icons.abc_rounded),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              TextFormField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  signed: false,
                  decimal: false,
                ),
                decoration: const InputDecoration(
                  label: Text("Quantity"),
                  icon: Icon(Icons.numbers),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              TextFormField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  signed: false,
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  label: Text("Price"),
                  icon: Icon(Icons.attach_money_rounded),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(labelSkipButton),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Product product = Product(
                        id: const Uuid().v1(),
                        name: nameController.text,
                        isBought: isBought,
                      );

                      if (model != null) {
                        product.id = model.id;
                      }

                      if (amountController.text != "") {
                        product.amount = double.parse(amountController.text);
                      }

                      if (priceController.text != "") {
                        product.price = double.parse(priceController.text);
                      }

                      productService.addProduct(
                        listinId: widget.listin.id,
                        product: product,                        
                      );

                      Navigator.pop(context);
                    },
                    child: Text(labelConfirmationButton),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  refresh({QuerySnapshot<Map<String, dynamic>>? snapshot}) async {
    List<Product> readOfProducts = await productService.readProducts(
        listinId: widget.listin.id,
        order: order,
        isDescendent: isDescendent,
        snapshot: snapshot);

    if (snapshot != null) {
      verifyBought(snapshot);
    }

    filterProduct(readOfProducts);
  }

  filterProduct(List<Product> listProducts) {
    List<Product> listPlanned = [];
    List<Product> listCaught = [];

    for (var product in listProducts) {
      if (product.isBought) {
        listCaught.add(product);
      } else {
        listPlanned.add(product);
      }
    }

    setState(() {
      listPlannedProducts = listPlanned;
      listProductsCaught = listCaught;
    });
  }

  setupListeners() {
    listener = productService.connectStream(
        onChange: refresh,
        listinId: widget.listin.id,
        order: order,
        isDescendent: isDescendent);
  }

  deleteProduct(Product product) async {
    await productService.removerproduct(
        product: product, listinId: widget.listin.id);
  }

  double calculateTotalCaught() {
    double total = 0;
    for (Product product in listProductsCaught) {
      if (product.price != null && product.amount != null) {
        total += product.price! * product.amount!;
      }
    }
    return total;
  }

  verifyBought(QuerySnapshot<Map<String, dynamic>> snapshot) {
    if (snapshot.docChanges.length == 1) {
      for (DocumentChange docChange in snapshot.docChanges) {
        String type = "";
        Color? color = Colors.black;
        switch (docChange.type) {
          case DocumentChangeType.added:
            type = "Products added";
            color = Colors.green[300];
            break;
          case DocumentChangeType.modified:
            type = "Product modified";
            color = Colors.blue[300];
            break;
          case DocumentChangeType.removed:
            type = "Product removed";
            color = Colors.red[300];
            break;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "$type: ${Product.fromMap(docChange.doc.data() as Map<String, dynamic>).name}"),
            backgroundColor: color,
          ),
        );
      }
    }
  }
}
