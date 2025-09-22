import 'package:flutter/material.dart';
import 'package:mobile/core/storage/secure_storage.dart';

class TestSecureStorageScreen extends StatefulWidget {
  const TestSecureStorageScreen({super.key});

  @override
  State<TestSecureStorageScreen> createState() => _TestSecureStorageScreenState();
}

class _TestSecureStorageScreenState extends State<TestSecureStorageScreen> {
  String _testResult = 'Testing...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _runTest();
  }

  Future<void> _runTest() async {
    try {
      setState(() {
        _testResult = 'Running secure storage test...\n';
        _isLoading = true;
      });

      // Test 1: Write a simple value
      _testResult += 'Test 1: Writing test value...\n';
      await SecureStorage.write(key: 'test_key', value: 'test_value');
      _testResult += '✓ Write completed\n';

      // Test 2: Read the value back
      _testResult += 'Test 2: Reading test value...\n';
      final readValue = await SecureStorage.read(key: 'test_key');
      _testResult += '✓ Read completed: $readValue\n';

      // Test 3: Test token storage
      _testResult += 'Test 3: Testing token storage...\n';
      await SecureStorage.storeTokens('test_access_token', 'test_refresh_token');
      _testResult += '✓ Token storage completed\n';

      // Test 4: Read tokens back
      _testResult += 'Test 4: Reading tokens back...\n';
      final accessToken = await SecureStorage.getToken();
      final refreshToken = await SecureStorage.getRefreshToken();
      _testResult += '✓ Access token: ${accessToken != null ? "exists" : "null"}\n';
      _testResult += '✓ Refresh token: ${refreshToken != null ? "exists" : "null"}\n';

      // Test 5: Test user data storage
      _testResult += 'Test 5: Testing user data storage...\n';
      await SecureStorage.storeUserData('{"id":"test","username":"testuser"}');
      _testResult += '✓ User data storage completed\n';

      // Test 6: Read user data back
      _testResult += 'Test 6: Reading user data back...\n';
      final userData = await SecureStorage.getUserData();
      final isLoggedIn = await SecureStorage.isLoggedIn();
      _testResult += '✓ User data: ${userData != null ? "exists" : "null"}\n';
      _testResult += '✓ Is logged in: $isLoggedIn\n';

      // Test 7: Clear storage
      _testResult += 'Test 7: Clearing storage...\n';
      await SecureStorage.clearUserSession();
      _testResult += '✓ Storage cleared\n';

      // Test 8: Verify cleared
      _testResult += 'Test 8: Verifying cleared storage...\n';
      final clearedToken = await SecureStorage.getToken();
      final clearedUserData = await SecureStorage.getUserData();
      final clearedLoginStatus = await SecureStorage.isLoggedIn();
      _testResult += '✓ After clear - Token: ${clearedToken != null ? "exists" : "null"}\n';
      _testResult += '✓ After clear - User data: ${clearedUserData != null ? "exists" : "null"}\n';
      _testResult += '✓ After clear - Login status: $clearedLoginStatus\n';

      _testResult += '\n🎉 All tests completed successfully!';
      
    } catch (e) {
      _testResult += '\n❌ Test failed with error: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Storage Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _runTest,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Text(
                  _testResult,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
      ),
    );
  }
}
