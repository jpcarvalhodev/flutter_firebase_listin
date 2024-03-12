import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_listin/authentication/components/show_password_confirmation_delete.dart';
import 'package:flutter_firebase_listin/authentication/services/auth_services.dart';
import 'package:flutter_firebase_listin/firestore/services/listin_services.dart';
import 'package:flutter_firebase_listin/firestore_product/presentation/product_screen.dart';
import 'package:flutter_firebase_listin/storage/screens/storage_screen.dart';
import 'package:uuid/uuid.dart';
import '../models/listin.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Listin> listListins = [];
  ListinService listinService = ListinService();

  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundImage: (widget.user.photoURL != null)
                    ? NetworkImage(widget.user.photoURL!)
                    : null,
              ),
              accountName: Text((widget.user.displayName != null)
                  ? widget.user.displayName!
                  : ""),
              accountEmail: Text(widget.user.email!),
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text("Profile Photo"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const StorageScreen();
                }));
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () {
                AuthServices().signOut();
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red[300]),
              title: const Text("Delete account"),
              onTap: () {
                showPasswordConfirmationDeleteDialog(
                    context: context, email: "");
              },
            )
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text("Listin"),
      ),
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.white,
        onPressed: () {
          showFormModal();
        },
        child: const Icon(Icons.add),
      ),
      body: (listListins.isEmpty)
          ? const Center(
              child: Text(
                "No list found.\nWant to create a list?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            )
          : RefreshIndicator(
              onRefresh: () {
                return refresh();
              },
              child: ListView(
                children: List.generate(
                  listListins.length,
                  (index) {
                    Listin model = listListins[index];
                    return Dismissible(
                      key: ValueKey<Listin>(model),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        padding: const EdgeInsets.only(right: 20),
                        alignment: Alignment.centerRight,
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: ((direction) {
                        remove(model);
                      }),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductScreen(listin: model),
                              ));
                        },
                        onLongPress: () {
                          showFormModal(model: model);
                        },
                        leading: const Icon(Icons.list_alt_rounded),
                        title: Text(model.name),
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }

  showFormModal({Listin? model}) {
    String title = "Add Listin";
    String confirmationButton = "Save";
    String skipButton = "Cancel";

    TextEditingController nameController = TextEditingController();

    if (model != null) {
      title = "Edit ${model.name}";
      nameController.text = model.name;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(32.0),
          child: ListView(
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(label: Text("Listin Name")),
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
                    child: Text(skipButton),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Listin listin = Listin(
                          id: const Uuid().v1(),
                          name: nameController.text,
                        );

                        if (model != null) {
                          listin.id = model.id;
                        }

                        listinService.addListin(listin: listin);
                        refresh();
                        Navigator.pop(context);
                      },
                      child: Text(confirmationButton)),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  refresh() async {
    List<Listin> listOfListins = await listinService.readListins();
    setState(() {
      listListins = listOfListins;
    });
  }

  void remove(Listin model) async {
    await listinService.removeListin(listinId: model.id);
    refresh();
  }
}
