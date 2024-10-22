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
  String account = '48682426';

  // controlador de texto
  final TextEditingController _accountController = TextEditingController();

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
        actions: [
          IconButton(
            onPressed: () {
              _userConfiguration();
            },
            icon: const Icon(
              Icons.account_circle_outlined,
              size: 30,
              color: Color.fromARGB(255, 145, 38, 109),
            ),
          ),
        ],
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
      "account": account,
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
      _successMovement();
      return true;
    } else if (response.statusCode == 400) {
      _insufficientFunds();
      return false;
    } else if (response.statusCode == 404) {
      _accountNotFound();
      return false;
    } else {
      _generalError();
      return false;
    }
  }

  void _successMovement() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            content: SizedBox(
          width: MediaQuery.of(context).size.width - 100,
          height: 260,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle_outline_outlined,
                  size: 50,
                  color: Color.fromARGB(255, 3, 138, 7),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Transaction completed successfully',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'The transaction has been completed successfully',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'))
              ],
            ),
          ),
        ));
      },
    );
  }

  void _amountZero() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            content: SizedBox(
          width: MediaQuery.of(context).size.width - 100,
          height: 260,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 50,
                  color: Color.fromARGB(255, 255, 154, 2),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Amount is zero',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'The amount to be charged must be greater than zero',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'))
              ],
            ),
          ),
        ));
      },
    );
  }

  void _insufficientFunds() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            content: SizedBox(
          width: MediaQuery.of(context).size.width - 100,
          height: 260,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error,
                  size: 50,
                  color: Colors.red,
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Insufficient funds',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'The account does not have enough funds to complete the transaction',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'))
              ],
            ),
          ),
        ));
      },
    );
  }

  void _generalError() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            content: SizedBox(
          width: MediaQuery.of(context).size.width - 100,
          height: 260,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error,
                  size: 50,
                  color: Colors.red,
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'General error',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'The transaction could not be completed, please try again later',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'))
              ],
            ),
          ),
        ));
      },
    );
  }

  void _accountNotFound() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            content: SizedBox(
          width: MediaQuery.of(context).size.width - 100,
          height: 260,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error,
                  size: 50,
                  color: Colors.red,
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Account not found',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'The account number does not exist, please verify the account number',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'))
              ],
            ),
          ),
        ));
      },
    );
  }

  Future<bool> _requestDeposit() async {
    setState(() {
      _isLoading = true;
    });

    var url = Uri.parse(
        'https://dw73vr1mj3.execute-api.us-east-1.amazonaws.com/prod/deposit-movement');
    var payload = {
      "account": account,
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
      _successMovement();
      return true;
    } else {
      _generalError();
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
          if (_amountValue == 0) {
            _amountZero();
            return;
          }
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

  void _userConfiguration() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            content: SizedBox(
          width: MediaQuery.of(context).size.width - 100,
          height: 400,
          child: _userConfigurationPopUp(),
        ));
      },
    );
  }

  Widget _userConfigurationPopUp() {
    String accountTemp = '';

    if (account.isEmpty) {
      accountTemp = 'No account';
    } else {
      accountTemp = account;
    }

    return Column(
      children: [
        const Text('Enter your account number', style: TextStyle(fontSize: 20)),
        const SizedBox(height: 10),
        Text('Actual account: $accountTemp',
            style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 10),
        TextField(
          keyboardType: TextInputType.number,
          controller: _accountController,
          onChanged: (value) {},
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter your account',
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            /*ElevatedButton(
              onPressed: () {
                account = "48682426";
                _accountController.clear();
                Navigator.of(context).pop();
              },
              child: const Text('P1'),
            ),
            ElevatedButton(
              onPressed: () {
                account = "17799331";
                _accountController.clear();
                Navigator.of(context).pop();
              },
              child: const Text('P2'),
            ),*/
            ElevatedButton(
              onPressed: () {
                account = _accountController.text;
                _accountController.clear();
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ],
    );
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
