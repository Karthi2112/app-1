import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hawk_monk/login.dart';
import 'package:hawk_monk/signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HawkMonk App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController invstController = TextEditingController();
  TextEditingController tenureController = TextEditingController();

  List<String> tenures = ['1 year', '2 years', '3 years', '4 years', '5 years'];
  List<String> payRhythms = [
    'Monthly',
    'Quarterly',
  ];

  String? selectedTenure;
  String? selectedPayRhythm;

  List<Widget> schemeCards = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Get.to(Login());
                  },
                  child: Text('Login'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    Get.to(Signup());
                  },
                  child: Text('Signup'),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            TextFormField(
              controller: invstController,
              decoration: const InputDecoration(
                hintText: 'Enter investment amount',
              ),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedTenure,
              items: tenures.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedTenure = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Select tenure',
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text('Select Pay Rhythm: '),
                for (String rhythm in payRhythms)
                  Row(
                    children: [
                      Radio<String>(
                        value: rhythm,
                        groupValue: selectedPayRhythm,
                        onChanged: (value) {
                          setState(() {
                            selectedPayRhythm = value;
                          });
                        },
                      ),
                      Text(rhythm),
                    ],
                  ),
              ],
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  double investmentAmount =
                      double.tryParse(invstController.text) ?? 0;

                  CollectionReference collRef =
                      FirebaseFirestore.instance.collection('inputs');
                  await collRef.add({
                    'invest_amount': invstController.text,
                    'pay_rhythm': selectedPayRhythm,
                    'tenure': selectedTenure,
                  });

                  QuerySnapshot schemeSnapshot = await FirebaseFirestore
                      .instance
                      .collection('scheme')
                      .where('invst', isLessThanOrEqualTo: investmentAmount)
                      .orderBy('invst', descending: true)
                      .get();

                  schemeCards = schemeSnapshot.docs.map((doc) {
                    return Card(
                      child: ListTile(
                        title: Text('Jewel Partner: ${doc['Jp']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Scheme Name: ${doc['scheme_name']}'),
                            Text('Investment: ${doc['invst']}'),
                            Text('Rating: ${doc['rating']}'),
                          ],
                        ),
                        trailing: Radio(
                          value: doc
                              .id, // Assuming doc.id is unique for each scheme
                          groupValue:
                              null, // Provide appropriate group value to manage radio buttons
                          onChanged: (value) async {
                            // Fetch scheme details for selected scheme
                            DocumentSnapshot schemeDetails = await FirebaseFirestore
                                .instance
                                .collection('scheme')
                                .doc(
                                    value) // Assuming value is the doc id of the selected scheme
                                .get();

                            // Show dialog with scheme details
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title:
                                      Text('${schemeDetails['scheme_name']}'),
                                  content: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                          ' ${schemeDetails['scheme_details']}'),
                                      Text('BENEFITS'),
                                      Text(' ${schemeDetails['benefits']}'),
                                      Text('CONDITIONS'),
                                      Text(
                                          ' ${schemeDetails['scheme_conditions']}'),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        // Proceed to pay action
                                        Navigator.of(context).pop();
                                        // Navigate to payment screen
                                      },
                                      child: Text('Proceed to Pay'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // Add to cart action
                                        Navigator.of(context).pop();
                                        // Add scheme to cart
                                      },
                                      child: Text('Add to Cart'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // Compare action
                                        Navigator.of(context).pop();
                                        // Compare schemes
                                      },
                                      child: Text('Compare'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                    );
                  }).toList();

                  // Update the UI to display the scheme cards
                  setState(() {});
                },
                child: Text('Submit'),
              ),
            ),
            SizedBox(height: 20),
            if (schemeCards.isNotEmpty) ...schemeCards,
          ],
        ),
      ),
    );
  }
}
