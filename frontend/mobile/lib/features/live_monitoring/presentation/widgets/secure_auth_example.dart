import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/widgets/custom_snackbar.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../authentication/presentation/bloc/authentication_bloc.dart';

/// Example widget showing how to use SecureStorageService in your clean architecture
class SecureAuthExample extends StatefulWidget {
  const SecureAuthExample({Key? key}) : super(key: key);

  @override
  State<SecureAuthExample> createState() => _SecureAuthExampleState();
}

class _SecureAuthExampleState extends State<SecureAuthExample> {
  String? _accessToken;
  String? _refreshToken;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Check authentication status using SecureStorage
    final isLoggedIn = await SecureStorage.isLoggedIn();
    setState(() => _isAuthenticated = isLoggedIn);

    // Get tokens directly from SecureStorage
    final accessToken = await SecureStorage.getToken();
    final refreshToken = await SecureStorage.getRefreshToken();

    setState(() {
      _accessToken = accessToken;
      _refreshToken = refreshToken;
    });
  }

  Future<void> _logout() async {
    // Use AuthenticationBloc for logout
    context.read<AuthenticationBloc>().add(LogoutEvent());

    setState(() {
      _isAuthenticated = false;
      _accessToken = null;
      _refreshToken = null;
    });

    CustomSnackbar.showError(context, 'Logged out successfully');
  }

  Future<void> _storeCustomData() async {
    // Example: Store user preferences securely
    await SecureStorage.storeUserData(
      '{"user_theme": "dark", "farm_id": "farm_12345"}',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Custom data stored securely')),
    );
  }

  Future<void> _retrieveCustomData() async {
    final userData = await SecureStorage.getUserData();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Stored Data'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text('User Data: ${userData ?? 'Not set'}')],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state.status == AuthenticationStatus.unauthenticated) {
          // Navigate to landing screen when logged out
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/landing', (route) => false);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Secure Storage Example')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Authentication Status
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Authentication Status',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            _isAuthenticated
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: _isAuthenticated ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isAuthenticated
                                ? 'Authenticated'
                                : 'Not Authenticated',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Token Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Stored Tokens',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Access Token: ${_accessToken != null ? '***${_accessToken!.substring(_accessToken!.length - 8)}' : 'None'}',
                      ),
                      Text(
                        'Refresh Token: ${_refreshToken != null ? '***${_refreshToken!.substring(_refreshToken!.length - 8)}' : 'None'}',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton(
                    onPressed: _checkAuthStatus,
                    child: const Text('Refresh Status'),
                  ),
                  if (_isAuthenticated)
                    ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Logout'),
                    ),
                  ElevatedButton(
                    onPressed: _storeCustomData,
                    child: const Text('Store Custom Data'),
                  ),
                  ElevatedButton(
                    onPressed: _retrieveCustomData,
                    child: const Text('Retrieve Custom Data'),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Usage Instructions
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How to Use Secure Storage',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        const Expanded(
                          child: SingleChildScrollView(
                            child: Text('''
1. **Dependency Injection**: SecureStorageService is automatically injected via GetIt

2. **Authentication Tokens**: 
   - Automatically stored during login/register
   - Used by Dio interceptor for API calls
   - Cleared during logout

3. **Custom Data Storage**:
   - Store user preferences securely
   - Store sensitive farm/sensor data
   - All data is encrypted on device

4. **Use Cases**:
   - CheckAuthStatusUseCase: Check if user is logged in
   - LogoutUseCase: Clear all stored data
   - Direct service access for UI needs

5. **Security Features**:
   - iOS: Keychain with first_unlock_this_device
   - Android: EncryptedSharedPreferences
   - Automatic token refresh via interceptor
   - Secure data clearing on logout

6. **Integration with BLoC**:
   - Use cases handle business logic
   - Service provides direct access
   - Clean separation of concerns
                            '''),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
