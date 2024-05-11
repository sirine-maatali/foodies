import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';
import 'dart:io';
import 'dart:math';

import '../service/database.dart';
import '../widget/widget_support.dart';
import 'add_food.dart';

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({Key? key}) : super(key: key);

  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  bool icecream = false, pizza = false, salad = false, burger = false;

  late Stream<QuerySnapshot> fooditemStream;

  final ImagePicker _picker = ImagePicker();
  File? selectedImage;

  void ontheload() async {
    fooditemStream = await DatabaseMethods().getFoodItem("pizza");
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    ontheload();
  }

  Future getImage() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      selectedImage = File(image!.path);
    });
  }

  Widget allItemsVertically() {
    return StreamBuilder<QuerySnapshot>(
      stream: fooditemStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final foodItems = snapshot.data!.docs;
          return SizedBox(
            height: 340, // Fixe la taille du conteneur
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: foodItems.length,
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                DocumentSnapshot ds = foodItems[index];
                return GestureDetector(
                  onTap: () {
                    // Gérer le clic sur l'élément
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 18.0, bottom: 20.0),
                    child: Material(
                      color: Color.fromARGB(255, 233, 98, 20),
                      elevation: 5.0,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                ds["Image"],
                                height: 120,
                                width: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 20.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width / 2.5,
                                  child: Text(
                                    ds["Name"],
                                    style: AppWidget.semiBoldTextFeildStyle(),
                                  ),
                                ),
                                SizedBox(height: 5.0),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width / 2.5,
                                  child: Text(
                                    ds["Detail"],
                                    style: AppWidget.LightTextFeildStyle(),
                                  ),
                                ),
                                SizedBox(height: 5.0),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width / 2.5,
                                  child: Text(
                                    ds["Price"].toString() + "\dt",
                                    style: AppWidget.semiBoldTextFeildStyle(),
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () async {
                                        String newName = ds["Name"];
                                        String newDetail = ds["Detail"];
                                        String newPrice = ds["Price"]
                                            .toString(); // Convertir le prix en String

                                        // Afficher la boîte de dialogue de mise à jour
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return StatefulBuilder(
                                              // Utiliser StatefulBuilder pour mettre à jour l'état des champs de texte
                                              builder: (BuildContext context,
                                                  setState) {
                                                // Boîte de dialogue de mise à jour
                                                return AlertDialog(
                                                  title: Text(
                                                      "Modifier l'aliment"),
                                                  content:
                                                      SingleChildScrollView(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        // Champ de texte pour le nom de l'aliment
                                                        Text(
                                                            "Nom de l'aliment"),
                                                        TextField(
                                                          controller:
                                                              TextEditingController(
                                                                  text:
                                                                      newName), // Utiliser un contrôleur pour afficher la valeur initiale
                                                          onChanged: (value) {
                                                            // Mettre à jour la nouvelle valeur du nom de l'aliment
                                                            newName = value;
                                                          },
                                                        ),
                                                        // Champ de texte pour les détails de l'aliment
                                                        Text(
                                                            "Détails de l'aliment"),
                                                        TextField(
                                                          controller:
                                                              TextEditingController(
                                                                  text:
                                                                      newDetail), // Utiliser un contrôleur pour afficher la valeur initiale
                                                          onChanged: (value) {
                                                            // Mettre à jour la nouvelle valeur des détails de l'aliment
                                                            newDetail = value;
                                                          },
                                                        ),
                                                        // Champ de texte pour le prix de l'aliment
                                                        Text(
                                                            "Prix de l'aliment"),
                                                        TextField(
                                                          controller:
                                                              TextEditingController(
                                                                  text:
                                                                      newPrice), // Utiliser un contrôleur pour afficher la valeur initiale
                                                          onChanged: (value) {
                                                            // Mettre à jour la nouvelle valeur du prix de l'aliment
                                                            newPrice = value;
                                                          },
                                                        ),
                                                        SizedBox(height: 10),
                                                        // Bouton pour sélectionner une nouvelle image
                                                        ElevatedButton(
                                                          onPressed: getImage,
                                                          child: Text(
                                                              "Choisir une nouvelle image"),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () async {
                                                        // Appeler la fonction updateFood avec les nouvelles valeurs
                                                        String collectionName =
                                                            ds.reference.parent!
                                                                .id;
                                                        String docId = ds.id;
                                                        // Construire le nouveau map de données avec les valeurs mises à jour
                                                        Map<String, dynamic>
                                                            updatedData = {
                                                          "Name": newName,
                                                          "Detail": newDetail,
                                                          "Price":
                                                              newPrice, // Convertir le prix en double
                                                        };
                                                        // Si une nouvelle image a été sélectionnée
                                                        if (selectedImage !=
                                                            null) {
                                                          // Télécharger la nouvelle image sur Firebase Storage
                                                          String addId =
                                                              randomAlphaNumeric(
                                                                  10);
                                                          Reference
                                                              firebaseStorageRef =
                                                              FirebaseStorage
                                                                  .instance
                                                                  .ref()
                                                                  .child(
                                                                      "blogImages")
                                                                  .child(addId);
                                                          final UploadTask
                                                              task =
                                                              firebaseStorageRef
                                                                  .putFile(
                                                                      selectedImage!);
                                                          // Attendre la fin du téléchargement et obtenir l'URL de téléchargement de l'image
                                                          var downloadUrl =
                                                              await (await task)
                                                                  .ref
                                                                  .getDownloadURL();
                                                          // Ajouter l'URL de l'image téléchargée aux données mises à jour
                                                          updatedData["Image"] =
                                                              downloadUrl;
                                                        }
                                                        // Appeler la fonction updateFood avec les nouvelles valeurs
                                                        await DatabaseMethods()
                                                            .updateFood(
                                                                collectionName,
                                                                docId,
                                                                updatedData);
                                                        // Fermer la boîte de dialogue après la mise à jour réussie
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child:
                                                          Text("Mettre à jour"),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        // Fermer la boîte de dialogue sans mettre à jour
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Text("Annuler"),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        );
                                      },
                                      icon: Icon(
                                        Icons.settings,
                                        color: Colors.white,
                                      ),
                                      iconSize: 30,
                                    ),
                                    SizedBox(width: 10),
                                    IconButton(
                                      onPressed: () async {
                                        String collectionName =
                                            ds.reference.parent!.id;
                                        String docId = ds.id;
                                        await DatabaseMethods()
                                            .deleteFood(collectionName, docId);
                                        // Afficher l'alerte après la suppression réussie
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title:
                                                  Text("Suppression réussie"),
                                              content: Text(
                                                  "L'aliment a été supprimé avec succès."),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(); // Fermer l'alerte
                                                  },
                                                  child: Text("OK"),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                      iconSize: 30,
                                    ),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
        child: Column(
          children: [
            Center(
              child: Text(
                "Home Admin",
                style: AppWidget.HeadlineTextFeildStyle(),
              ),
            ),
            SizedBox(height: 50.0),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddFood()));
              },
              child: Material(
                elevation: 10.0,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(6.0),
                        child: Image.asset(
                          "images/food.jpg",
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 30.0),
                      Text(
                        "Add Food Items",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () async {
                    icecream = true;
                    pizza = false;
                    salad = false;
                    burger = false;

                    fooditemStream =
                        await DatabaseMethods().getFoodItem("Ice-cream");
                    setState(() {});
                  },
                  child: Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      decoration: BoxDecoration(
                          color: icecream ? Colors.black : Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(
                        "images/ice-cream.png",
                        height: 35,
                        width: 35,
                        fit: BoxFit.cover,
                        color: icecream ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    icecream = false;
                    pizza = true;
                    salad = false;
                    burger = false;

                    fooditemStream =
                        await DatabaseMethods().getFoodItem("Pizza");

                    setState(() {});
                  },
                  child: Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      decoration: BoxDecoration(
                          color: pizza ? Colors.black : Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(
                        "images/pizza.png",
                        height: 35,
                        width: 35,
                        fit: BoxFit.cover,
                        color: pizza ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    icecream = false;
                    pizza = false;
                    salad = true;
                    burger = false;
                    setState(() {});
                    fooditemStream =
                        await DatabaseMethods().getFoodItem("Salad");
                  },
                  child: Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      decoration: BoxDecoration(
                          color: salad ? Colors.black : Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(
                        "images/salad.png",
                        height: 35,
                        width: 35,
                        fit: BoxFit.cover,
                        color: salad ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    icecream = false;
                    pizza = false;
                    salad = false;
                    burger = true;
                    setState(() {});

                    fooditemStream =
                        await DatabaseMethods().getFoodItem("Burger");
                  },
                  child: Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      decoration: BoxDecoration(
                          color: burger ? Colors.black : Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(
                        "images/burger.png",
                        height: 35,
                        width: 35,
                        fit: BoxFit.cover,
                        color: burger ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 30.0,
            ),
            allItemsVertically(),
          ],
        ),
      ),
    );
  }
}
