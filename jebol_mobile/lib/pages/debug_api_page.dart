import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

/// DEBUG PAGE - Only accessible in development mode.
/// This page is for API testing during development only.
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

  void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint('[DEBUG_API] $message');
    }
  }

  Future<void> _loginAndTest() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    try {
      _debugLog('Calling login...');
      final loginResp = await _api.login(username, password);
      _debugLog('LOGIN RESPONSE: $loginResp');

      if (loginResp['success'] == true) {
        try {
          _debugLog('Fetching admin perkawinan list (PENDING)');
          final listResp = await _api.getAdminPerkawinanList(
            status: 'PENDING',
            page: 1,
          );
          _debugLog('LIST RESPONSE: data=${listResp['data']}');
          _debugLog('LIST RESPONSE: meta=${listResp['meta']}');
        } catch (e, s) {
          _debugLog('Error fetching list: $e\n$s');
        }
      } else {
        _debugLog('Login unsuccessful, skipping list fetch');
      }
    } catch (e, s) {
      _debugLog('Unexpected error during login/test: $e\n$s');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only show in debug mode
    if (!kDebugMode) {
      return const Scaffold(
        body: Center(child: Text('Debug page not available in release mode')),
      );
    }

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
                try {
                  final username = _usernameController.text.trim();
                  final password = _passwordController.text;
                  _debugLog('Calling login (only)...');
                  final r = await _api.login(username, password);
                  _debugLog('LOGIN ONLY RESPONSE: $r');
                } catch (e, s) {
                  _debugLog('Login only error: $e\n$s');
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
