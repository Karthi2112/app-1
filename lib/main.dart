import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hawk_monk/login.dart';
import 'package:hawk_monk/signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    final invstcontroller = TextEditingController();
    final tenurecontroller = TextEditingController();
    final payrhythmcontroller = TextEditingController();

    return GetMaterialApp(
      title: 'HawkMonk App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
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
              Text('Welcome to HawkMonk', style: TextStyle(fontSize: 26)),
              Text(
                'Hawk Monk Fintech services to its clients, including algorithmic trading strategies for stocks, futures, and options, portfolio optimization, and risk management.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: invstcontroller,
                decoration: const InputDecoration(
                  hintText: 'Enter investment amount',
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: tenurecontroller,
                decoration: const InputDecoration(
                  hintText: 'Enter tenure',
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: payrhythmcontroller,
                decoration: const InputDecoration(
                  hintText: 'Enter Payrhythm',
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    double investmentAmount =
                        double.tryParse(invstcontroller.text) ?? 0;

                    CollectionReference collRef =
                        FirebaseFirestore.instance.collection('inputs');
                    await collRef.add({
                      'invest_amount': invstcontroller.text,
                      'pay_rhythm': payrhythmcontroller.text,
                      'tenure': tenurecontroller.text,
                    });

                    QuerySnapshot schemeSnapshot = await FirebaseFirestore
                        .instance
                        .collection('scheme')
                        .where('invst', isLessThanOrEqualTo: investmentAmount)
                        .orderBy('invst', descending: true)
                        .get();

                    List<Widget> schemeCards = schemeSnapshot.docs.map((doc) {
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
                        ),
                      );
                    }).toList();

                    Get.dialog(
                      AlertDialog(
                        title: Text('Scheme Details'),
                        content: SingleChildScrollView(
                          child: Column(
                            children: schemeCards,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
