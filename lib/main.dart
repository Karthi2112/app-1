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
  String? selectedTenure;
  String? selectedPayRhythm;

  List<String> payRhythms = ['Monthly', 'Half-yearly', 'Yearly'];

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
              items: [
                '12 Months',
                '15 Months',
                '18 Monthss',
                '24 Monthss',
                '36 Months'
              ].map((String value) {
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
            Container(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: payRhythms.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        Text(payRhythms[index]),
                        Radio<String>(
                          value: payRhythms[index],
                          groupValue: selectedPayRhythm,
                          onChanged: (String? value) {
                            setState(() {
                              selectedPayRhythm = value;
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
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

                  // Process the scheme details as needed
                },
                child: Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
