import 'package:flutter/material.dart';
import 'package:mobile/core/services/session_service.dart';
import 'package:mobile/core/storage/secure_storage.dart';

class DebugSessionScreen extends StatefulWidget {
  const DebugSessionScreen({super.key});

  @override
  State<DebugSessionScreen> createState() => _DebugSessionScreenState();
}

class _DebugSessionScreenState extends State<DebugSessionScreen> {
  String _debugInfo = 'Loading...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDebugInfo();
  }

  Future<void> _loadDebugInfo() async {
    try {
      final sessionService = SessionService();
      await sessionService.initialize();
      
      final hasToken = await SecureStorage.getToken();
      final hasRefreshToken = await SecureStorage.getRefreshToken();
      final hasUserData = await SecureStorage.getUserData();
      final isLoggedIn = await SecureStorage.isLoggedIn();
      final isSessionActive = sessionService.isSessionActive;
      
      setState(() {
        _debugInfo = '''
Session Debug Information:
=======================
Session Active: $isSessionActive
Has Access Token: ${hasToken != null}
Has Refresh Token: ${hasRefreshToken != null}
Has User Data: ${hasUserData != null}
Is Logged In: $isLoggedIn

Token Preview: ${hasToken != null ? hasToken.substring(0, 20) + '...' : 'null'}
Refresh Token Preview: ${hasRefreshToken != null ? hasRefreshToken.substring(0, 20) + '...' : 'null'}
User Data Preview: ${hasUserData != null ? hasUserData.substring(0, 100) + '...' : 'null'}
        ''';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _debugInfo = 'Error loading debug info: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Debug'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDebugInfo,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Text(
                  _debugInfo,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
      ),
    );
  }
}
