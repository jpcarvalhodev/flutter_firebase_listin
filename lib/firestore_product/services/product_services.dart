import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_firebase_listin/firestore_product/helpers/enum_order.dart';
import 'package:flutter_firebase_listin/firestore_product/models/product.dart';

class ProductService {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  addProduct({required String listinId, required Product product}) {
    firestore
        .collection("listins")
        .doc(listinId)
        .collection("products")
        .doc(product.id)
        .set(product.toMap());
  }

  Future<List<Product>> readProducts(
      {required String listinId,
      required OrderProducts order,
      required bool isDescendent,
      QuerySnapshot<Map<String, dynamic>>? snapshot}) async {
    List<Product> temp = [];
    snapshot ??= await firestore
        .collection("listins")
        .doc(listinId)
        .collection("products")
        .orderBy(order.name, descending: isDescendent)
        .get();

    for (var doc in snapshot.docs) {
      Product product = Product.fromMap(doc.data());
      temp.add(product);
    }

    return temp;
  }

  changeBoughtStatus(
      {required Product product, required String listinId}) async {
    product.isBought = !product.isBought;
    return firestore
        .collection("listins")
        .doc(listinId)
        .collection("products")
        .doc(product.id)
        .update({"isBought": product.isBought});
  }

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>> connectStream({
    required Function onChange,
    required String listinId,
    required OrderProducts order,
    required bool isDescendent,
  }) {
    return firestore
        .collection("listins")
        .doc(listinId)
        .collection("products")
        .orderBy(order.name, descending: isDescendent)
        .snapshots()
        .listen(
      (snapshot) {
        onChange(snapshot: snapshot);
      },
    );
  }

  Future<void> removerproduct(
      {required Product product, required String listinId}) async {
    return await firestore
        .collection("listins")
        .doc(listinId)
        .collection("products")
        .doc(product.id)
        .delete();
  }
}
