import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bkash/flutter_bkash.dart';

void main(){
  runApp(const MyApp());
}
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyWidget(),
    );
  }
}

class MyWidget extends StatefulWidget {
  const MyWidget({Key? key}) : super(key: key);

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {

  TextEditingController totalAmount = TextEditingController();

  void showSnack(context, message){
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: message,
          action: SnackBarAction(
            onPressed: (){Navigator.pop(context);},
            label: "OK",
          ),
        )
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bkash Payment"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 200.0,
                  height: 50.0,
                  child: TextField(
                      keyboardType: TextInputType.number,
                      controller: totalAmount,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(),
                          labelText: "Enter Amount"
                      )
                  ),
                ),

                const SizedBox(height: 20.0,),

                SizedBox(
                  width: 200.0,
                  height: 50.0,
                  child: ElevatedButton(
                    onPressed: (){
                      Navigator.push(context, CupertinoPageRoute(builder: (context)=>
                          BkashPayment(
                            // depend isSandbox (true/false)
                            isSandbox: true,
                            // amount of your bkash payment
                            amount: totalAmount.text,
                            /// intent would be (sale / authorization)
                            intent: 'sale',
                            // accessToken: '', /// if the user have own access token for verify payment
                            // currency: 'BDT',
                            /// bkash url for create payment, when you implement on you project then it be change as your production create url, [when you send it on sandbox mode, send it as empty string '' or anything]
                            createBKashUrl: 'https://merchantserver.sandbox.bka.sh/api/checkout/v1.2.0-beta/payment/create',
                            /// bkash url for execute payment, , when you implement on you project then it be change as your production create url, [when you send it on sandbox mode, send it as empty string '' or anything]
                            executeBKashUrl: 'https://merchantserver.sandbox.bka.sh/api/checkout/v1.2.0-beta/payment/execute',
                            /// for script url, when you implement on production the set it live script js (https://scripts.pay.bka.sh/versions/1.2.0-beta/checkout/bKash-checkout-pay.js)
                            scriptUrl: 'https://scripts.sandbox.bka.sh/versions/1.2.0-beta/checkout/bKash-checkout-sandbox.js',
                            /// the return value from the package
                            /// status => 'paymentSuccess', 'paymentFailed', 'paymentError', 'paymentClose'
                            /// data => return value of response

                            paymentStatus: (status, data) {
                              //dev.log('return status => $status');
                              //dev.log('return data => $data');

                              /// when payment success
                              if (status == 'paymentSuccess') {
                                if (data['transactionStatus'] == 'Completed') {
                                  showSnack(context, "Payment Success");
                                }
                              }

                              /// when payment failed
                              else if (status == 'paymentFailed') {
                                if (data.isEmpty) {
                                  showSnack(context, 'Payment Failed');
                                } else if (data[0]['errorMessage'].toString() != 'null'){
                                  showSnack(context, "Payment Failed ${data[0]['errorMessage']}");
                                } else {
                                  showSnack(context, 'Payment Failed');
                                }
                              }

                              /// when payment on error
                              else if (status == 'paymentError') {
                                showSnack(context, jsonDecode(data['responseText'])['error']);
                              }

                              /// when payment close on demand closed the windows
                              else if (status == 'paymentClose') {
                                if (data == 'closedWindow') {
                                   showSnack(context, 'Failed to payment, closed screen');
                                } else if (data == 'scriptLoadedFailed') {
                                  showSnack(context, 'Payment screen loading failed');
                                }
                              }
                              /// back to screen to pop()
                              Navigator.of(context).pop();
                            },
                          )
                      )
                      );
                    },
                    child: const Text("PAY NOW"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

