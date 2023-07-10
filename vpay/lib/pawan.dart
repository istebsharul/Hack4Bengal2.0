import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyHomePage2 extends StatefulWidget {
  const MyHomePage2({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage2> {
  List<dynamic> _users = [];
  List<dynamic> _payments = [];
  TextEditingController _payerController = TextEditingController();
  TextEditingController _payeeController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _availableAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getUsers();
    getPayments();
  }

  void getUsers() async {
    final response = await http.get(Uri.parse('http://localhost:5000/users'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _users = data['users'];
      });
    }
  }

  void createPayment() async {
    final payer = _payerController.text;
    final payee = _payeeController.text;
    final amount = double.parse(_amountController.text);

    final existingPayee = _users.firstWhere(
      (user) => user['username'] == payee,
      orElse: () => null,
    );

    if (existingPayee != null) {
      final response = await http.post(
        Uri.parse('http://localhost:5000/payments'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'payer': payer,
          'payee': payee,
          'amount': amount,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _users = data['users'];
        });
        _payerController.clear();
        _payeeController.clear();
        _amountController.clear();
      }
    } else {
      final response = await http.post(
        Uri.parse('http://localhost:5000/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': payee,
          'available_amount': 0,
        }),
      );

      if (response.statusCode == 200) {
        getUsers();
        createPayment();
      }
    }
  }

  void getPayments() async {
    final response =
        await http.get(Uri.parse('http://localhost:5000/payments'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _payments = data['payments'];
      });
    }
  }

  void createUser(String username, double availableAmount) async {
    final response = await http.post(
      Uri.parse('http://localhost:5000/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'available_amount': availableAmount,
      }),
    );

    if (response.statusCode == 200) {
      getUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Users',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return ListTile(
                  title: Text('Username: ${user['username']}'),
                  subtitle:
                      Text('Available Amount: ${user['available_amount']}'),
                );
              },
            ),
          ),
          SizedBox(height: 20),

          // Create new User
          Text(
            'Create New User',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'Username',
            ),
          ),
          TextField(
            controller: _availableAmountController,
            decoration: InputDecoration(
              labelText: 'Available Amount',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              final username = _usernameController.text;
              final availableAmount =
                  double.parse(_availableAmountController.text);
              createUser(username, availableAmount);
              _usernameController.clear();
              _availableAmountController.clear();
            },
            child: Text('Create User'),
          ),

          //Make Payment Section
          SizedBox(height: 20),
          Text(
            'Make Payment',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _payerController,
            decoration: InputDecoration(
              labelText: 'Payer',
            ),
          ),
          TextField(
            controller: _payeeController,
            decoration: InputDecoration(
              labelText: 'Payee',
            ),
          ),
          TextField(
            controller: _amountController,
            decoration: InputDecoration(
              labelText: 'Amount',
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: createPayment,
            child: Text('Make Payment'),
          ),
        ],
      ),
    );
  }
}
