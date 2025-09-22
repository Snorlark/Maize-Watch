import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/constants/app_spacing.dart';
import 'package:mobile/core/theme/colors.dart';
import 'package:mobile/features/authentication/presentation/bloc/authentication_bloc.dart';
import 'package:mobile/features/settings/presentation/screens/settings_screen.dart';
import 'package:mobile/features/settings/presentation/screens/about_screen.dart';
import 'package:mobile/generated/l10n.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MAIZE_PRIMARY_LIGHT,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            SizedBox(height: kAppLargePadding),
            
            // User Information Card
            _buildUserInfoCard(),
            SizedBox(height: kAppLargePadding),
            
            // Settings and About Cards
            _buildNavigationCards(),
            SizedBox(height: kAppLargePadding),
            
            // Logout Button
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(kAppMediumPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.of(context).account,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: MAIZE_ACCENT,
                ),
              ),
              verticalSpace(2.h),
              Text(
                S.of(context).about_user,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: MAIZE_ACCENT,
                ),
              ),
            ],
          ),        
        ],
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        if (state.status == AuthenticationStatus.authenticated && state.user != null) {
          final user = state.user!;
          return Container(
            margin: EdgeInsets.symmetric(horizontal: kAppMediumPadding),
            padding: EdgeInsets.all(kAppLargePadding),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      user.username,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: MAIZE_ACCENT,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // TODO: Implement edit user functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Edit functionality coming soon'),
                            backgroundColor: MAIZE_ACCENT,
                          ),
                        );
                      },
                      child: Icon(
                        Icons.edit,
                        color: Colors.grey,
                        size: 20.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: kAppMediumPadding),
                _buildUserInfoRow('Name', user.fullName),
                SizedBox(height: kAppSmallPadding),
                _buildUserInfoRow('Contact No.', user.contactNumber),
                SizedBox(height: kAppSmallPadding),
                _buildUserInfoRow('Address', _formatAddress(user.address)),
              ],
            ),
          );
        }
        
        // Loading state
        return Container(
          margin: EdgeInsets.symmetric(horizontal: kAppMediumPadding),
          padding: EdgeInsets.all(kAppLargePadding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: MAIZE_ACCENT,
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100.w,
          child: Text(
            '$label :',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationCards() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: kAppMediumPadding),
      child: Column(
        children: [
          _buildNavigationCard(
            title: S.of(context).settings,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
          SizedBox(height: kAppSmallPadding),
          _buildNavigationCard(
            title: S.of(context).about,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AboutScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationCard({
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(kAppMediumPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: MAIZE_ACCENT,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: kAppMediumPadding),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            _showLogoutDialog();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: MAIZE_ACCENT,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: kAppMediumPadding),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            elevation: 2,
          ),
          child: Text(
            S.of(context).logout,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).logout_title),
        content: Text(S.of(context).logout_message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(S.of(context).cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthenticationBloc>().add(LogoutEvent());
            },
            child: Text(S.of(context).logout),
          ),
        ],
      ),
    );
  }

  String _formatAddress(Map<String, dynamic> address) {
    // Format address from the structured data
    final parts = <String>[];
    
    if (address['barangay']?.isNotEmpty == true) {
      parts.add(address['barangay']);
    }
    if (address['municipality']?.isNotEmpty == true) {
      parts.add(address['municipality']);
    }
    if (address['province']?.isNotEmpty == true) {
      parts.add(address['province']);
    }
    if (address['region']?.isNotEmpty == true) {
      parts.add(address['region']);
    }
    
    return parts.isNotEmpty ? parts.join(', ') : 'No address provided';
  }
}
