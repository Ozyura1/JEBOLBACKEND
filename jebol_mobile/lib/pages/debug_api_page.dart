import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DebugApiPage extends StatefulWidget {
  const DebugApiPage({super.key});

  @override
  State<DebugApiPage> createState() => _DebugApiPageState();
}

class _DebugApiPageState extends State<DebugApiPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _api = ApiService();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginAndTest() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    final payload = {'username': username, 'password': password};
    try {
      print('Calling login with payload: $payload');
      final loginResp = await _api.login(username, password);
      print('LOGIN RESPONSE: $loginResp');

      if (loginResp['success'] == true) {
        try {
          print('Fetching admin perkawinan list (PENDING)');
          final listResp = await _api.getAdminPerkawinanList(status: 'PENDING', page: 1);
          print('LIST RESPONSE: data=${listResp['data']}');
          print('LIST RESPONSE: meta=${listResp['meta']}');
        } catch (e, s) {
          print('Error fetching list: $e');
          print(s);
        }
      } else {
        print('Login unsuccessful, skipping list fetch');
      }
    } catch (e, s) {
      print('Unexpected error during login/test: $e');
      print(s);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug API Page')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loginAndTest,
              child: const Text('LOGIN & TEST API'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                // quick login-only call
                try {
                  final username = _usernameController.text.trim();
                  final password = _passwordController.text;
                  final payload = {'username': username, 'password': password};
                  print('Calling login (only) with payload: $payload');
                  final r = await _api.login(username, password);
                  print('LOGIN ONLY RESPONSE: $r');
                } catch (e, s) {
                  print('Login only error: $e');
                  print(s);
                }
              },
              child: const Text('LOGIN ONLY'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CLOSE'),
            ),
          ],
        ),
      ),
    );
  }
}
