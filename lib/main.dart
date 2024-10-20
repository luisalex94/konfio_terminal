import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Konfio terminal'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isPayments = true;
  bool _isLoading = false;
  double _amountValue = 0.0;
  String response = '';

  void _paymentsButton() {
    setState(() {
      _isPayments = true;
    });
  }

  void _chargebacksButton() {
    setState(() {
      _isPayments = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Image.asset('assets/konfio_logo_cuadrado.png'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: body(),
    );
  }

  Widget body() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Column(
            children: [
              const SizedBox(height: 20),
              buttons(),
              const SizedBox(height: 120),
              amountBox(),
            ],
          ),
          Column(
            children: [
              const SizedBox(height: 20),
              numericalKeyboard(),
              const SizedBox(height: 20),
              actionButton(),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }

  Future<bool> _requestCharge() async {
    setState(() {
      _isLoading = true;
    });
    var url = Uri.parse(
        'https://dw73vr1mj3.execute-api.us-east-1.amazonaws.com/prod/charge-movement');
    var payload = {
      "account": "48682426",
      "concept": "Terminal - 001 - charge",
      "amount": _amountValue,
      "date": DateTime.now().toIso8601String(),
    };
    // convierte payload a json
    var payloadJson = jsonEncode(payload);

    var response = await http.post(url, body: payloadJson);

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _requestDeposit() async {
    setState(() {
      _isLoading = true;
    });

    var url = Uri.parse(
        'https://dw73vr1mj3.execute-api.us-east-1.amazonaws.com/prod/deposit-movement');
    var payload = {
      "account": "48682426",
      "concept": "Terminal - 001 - deposit",
      "amount": _amountValue,
      "date": DateTime.now().toIso8601String(),
    };
    var payloadJson = jsonEncode(payload);

    var response = await http.post(url, body: payloadJson);

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Widget buttons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        ElevatedButton(
            onPressed: _paymentsButton,
            style: ElevatedButton.styleFrom(
                backgroundColor: _isPayments ? Colors.amber : Colors.white,
                fixedSize: const Size(160, 40)),
            child: const Text('Payments')),
        ElevatedButton(
          onPressed: _chargebacksButton,
          style: ElevatedButton.styleFrom(
              backgroundColor: _isPayments ? Colors.white : Colors.amber,
              fixedSize: const Size(160, 40)),
          child: const Text('Chargebacks'),
        ),
      ],
    );
  }

  Widget amountBox() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        //border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '\$ ${_amountValue.toStringAsFixed(2)}',
        style: const TextStyle(
            fontSize: 46, color: Color.fromARGB(255, 135, 13, 139)),
      ),
    );
  }

  Widget actionButton() {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 100,
      height: 60,
      child: ElevatedButton(
        onPressed: () {
          if (_isPayments) {
            _requestCharge();
          } else {
            _requestDeposit();
          }
        },
        style: ElevatedButton.styleFrom(),
        child: _isLoading
            ? const CircularProgressIndicator()
            : Text(_isPayments ? 'Charge' : 'Refund'),
      ),
    );
  }

  void _amountValueString(String data) {
    if (double.tryParse(data) != null) {
      response = response + data.toString();
    } else if (data == 'backspace' && response.isNotEmpty) {
      response = response.substring(0, response.length - 1);
    } else if (data == 'clear') {
      response = '';
    }
    setState(() {
      _amountValue = (response.isEmpty ? 0.0 : double.parse(response)) / 100;
    });
  }

  Widget numericalKeyboard() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                _amountValueString('1');
              },
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
              ),
              child: const Text(
                '1',
                style: TextStyle(fontSize: 24),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _amountValueString('2');
              },
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
              ),
              child: const Text(
                '2',
                style: TextStyle(fontSize: 24),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _amountValueString('3');
              },
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
              ),
              child: const Text(
                '3',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                _amountValueString('4');
              },
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
              ),
              child: const Text(
                '4',
                style: TextStyle(fontSize: 24),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _amountValueString('5');
              },
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
              ),
              child: const Text(
                '5',
                style: TextStyle(fontSize: 24),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _amountValueString('6');
              },
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
              ),
              child: const Text(
                '6',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                _amountValueString('7');
              },
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
              ),
              child: const Text(
                '7',
                style: TextStyle(fontSize: 24),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _amountValueString('8');
              },
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
              ),
              child: const Text(
                '8',
                style: TextStyle(fontSize: 24),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _amountValueString('9');
              },
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
              ),
              child: const Text(
                '9',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                _amountValueString('clear');
              },
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
              ),
              child: const Icon(Icons.clear),
            ),
            ElevatedButton(
              onPressed: () {
                _amountValueString('0');
              },
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
              ),
              child: const Text(
                '0',
                style: TextStyle(fontSize: 24),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _amountValueString('backspace');
              },
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
              ),
              child: const Icon(Icons.backspace_outlined),
            ),
          ],
        ),
      ],
    );
  }
}
