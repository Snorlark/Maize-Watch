import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/constants/app_spacing.dart';
import 'package:mobile/core/theme/colors.dart';
import 'package:mobile/features/authentication/presentation/bloc/authentication_bloc.dart';
import 'package:mobile/core/constants/philippine_regions.dart';
import 'package:mobile/core/constants/address_data.dart';
import 'package:mobile/features/authentication/presentation/utils/ui_form_validators.dart';

import '../../../../core/widgets/custom_button.dart';
import '../../../../generated/l10n.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  
  // Structured address controllers (same as registration)
  final _regionController = TextEditingController();
  final _provinceController = TextEditingController();
  final _municipalityController = TextEditingController();
  final _barangayController = TextEditingController();
  
  bool _isEditing = false;
  bool _isLoading = false;

  // Track selected values for cascading dropdowns
  String? selectedRegion;
  String? selectedProvince;
  String? selectedMunicipality;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final state = context.read<AuthenticationBloc>().state;
    if (state.status == AuthenticationStatus.authenticated && state.user != null) {
      final user = state.user!;
      
      // Split full name into first and last name
      final nameParts = user.fullName.split(' ');
      if (nameParts.isNotEmpty) {
        _firstNameController.text = nameParts.first;
        if (nameParts.length > 1) {
          _lastNameController.text = nameParts.sublist(1).join(' ');
        }
      }
      
      _contactNumberController.text = user.contactNumber;
      _loadAddressData(user.address);
    }
  }

  void _loadAddressData(dynamic address) {
    if (address is Map<String, dynamic>) {
      final region = address['region']?.toString() ?? '';
      final province = address['province']?.toString() ?? '';
      final municipality = address['municipality']?.toString() ?? '';
      final barangay = address['barangay']?.toString() ?? '';
      
      _regionController.text = region;
      _provinceController.text = province;
      _municipalityController.text = municipality;
      _barangayController.text = barangay;
      
      // Set selected values for cascading dropdowns
      setState(() {
        selectedRegion = region.isNotEmpty ? region : null;
        selectedProvince = province.isNotEmpty ? province : null;
        selectedMunicipality = municipality.isNotEmpty ? municipality : null;
      });
    } else {
      // Clear all fields if address is not in expected format
      _regionController.clear();
      _provinceController.clear();
      _municipalityController.clear();
      _barangayController.clear();
      
      setState(() {
        selectedRegion = null;
        selectedProvince = null;
        selectedMunicipality = null;
      });
    }
  }

  String _formatAddress(dynamic address) {
    print('🔍 _formatAddress called with: $address (type: ${address.runtimeType})');
    
    if (address == null) return 'Not provided';
    
    if (address is String) {
      print('🔍 Address is String: $address');
      return address.isEmpty ? 'Not provided' : address;
    }
    
    if (address is Map<String, dynamic>) {
      print('🔍 Address is Map: $address');
      List<String> addressParts = [];
      if (address['barangay'] != null && address['barangay'].toString().isNotEmpty) {
        addressParts.add(address['barangay'].toString());
      }
      if (address['municipality'] != null && address['municipality'].toString().isNotEmpty) {
        addressParts.add(address['municipality'].toString());
      }
      if (address['province'] != null && address['province'].toString().isNotEmpty) {
        addressParts.add(address['province'].toString());
      }
      if (address['region'] != null && address['region'].toString().isNotEmpty) {
        addressParts.add(address['region'].toString());
      }
      
      final result = addressParts.isEmpty ? 'Not provided' : addressParts.join(', ');
      print('🔍 Formatted address result: $result');
      return result;
    }
    
    print('🔍 Address is unknown type, returning "Not provided"');
    return S.of(context).null_value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: MAIZE_PRIMARY_LIGHT,
      appBar: AppBar(        
        backgroundColor: MAIZE_PRIMARY_LIGHT,
        leading: IconButton(onPressed: () {
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back, color: MAIZE_ACCENT,)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _isEditing ? _buildEditForm() : _buildProfileSection(),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(kAppMediumPadding),
        child: SingleChildScrollView(
          child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
            builder: (context, state) {
              if (state.status == AuthenticationStatus.authenticated && state.user != null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [                 
                    Text(S.of(context).account, style: Theme.of(context).textTheme.headlineMedium,),
                    verticalSpace(5.h),
                    Text(S.of(context).your_personal_information, style: Theme.of(context).textTheme.bodySmall,),   
                    verticalSpace(kAppLargeGap),
                     _buildMenuItem(
                       title: 'Username',
                       subtitle: '@${state.user?.username}',
                       icon: Icons.person,
                       isFullWidth: true,
                     ),
                    verticalSpace(kAppSmallGap),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMenuItem(
                            title: 'First Name',
                            subtitle: '${state.user?.fullName.split(' ')[0]}',
                            icon: Icons.person_outline,
                          ),
                        ),
                        SizedBox(width: kAppSmallGap),
                        Expanded(
                          child: _buildMenuItem(
                            title: 'Last Name',
                            subtitle: '${state.user?.fullName.split(' ')[1]}',
                            icon: Icons.person_outline,
                          ),
                        ),
                      ],
                    ),
                    verticalSpace(kAppSmallGap),
                     _buildMenuItem(
                       title: 'Contact Number',
                       subtitle: '${state.user?.contactNumber}',
                       icon: Icons.phone,
                       isFullWidth: true,
                     ),
                    verticalSpace(kAppSmallGap),
                     _buildMenuItem(
                       title: 'Address',
                       subtitle: _formatAddress(state.user?.address),
                       icon: Icons.location_on,
                       isFullWidth: true,
                     ),
                    verticalSpace(kAppLargeGap), // Add some bottom padding
                  ],
                );
              }
              
              return Center(
                child: CircularProgressIndicator(
                  color: MAIZE_ACCENT,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required String title,
    required String subtitle,
    required IconData icon,
    bool isFullWidth = false,
  }) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: EdgeInsets.all(kAppMediumPadding),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white),
      ),
        child: Row(
          mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: MAIZE_ACCENT.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Icon(
                icon,
                color: MAIZE_ACCENT,
                size: 20.sp,
              ),
            ),
            SizedBox(width: kAppSmallGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MAIZE_ACCENT.withOpacity(0.8)),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),             
          ],
        ),
    );
  }


  Widget _buildEditForm() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(kAppMediumPadding),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Profile',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                verticalSpace(5.h),
                Text(
                  'Update your personal information',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                verticalSpace(kAppLargeGap),
                
                // First Name Field
                _buildInputField(
                  'First Name',
                  'Enter your first name',
                  _firstNameController,
                  validator: UIFormValidators.firstNameValidator(context),
                ),
                verticalSpace(20.h),
                
                // Last Name Field
                _buildInputField(
                  'Last Name',
                  'Enter your last name',
                  _lastNameController,
                  validator: UIFormValidators.lastNameValidator(context),
                ),
                verticalSpace(20.h),
                
                // Contact Number Field
                _buildInputField(
                  'Contact Number',
                  '09123456789',
                  _contactNumberController,
                  showPHPrefix: true,
                  validator: UIFormValidators.contactNumberValidator(context),
                ),
                verticalSpace(20.h),
                
                // Region Dropdown
                _buildResponsiveDropdownField(
                  'Region',
                  'Select Region',
                  _regionController,
                  PhilippineRegions.regions,
                  validator: UIFormValidators.regionValidator(context),
                  onChanged: (value) {
                    setState(() {
                      selectedRegion = value;
                      selectedProvince = null;
                      selectedMunicipality = null;
                      _provinceController.clear();
                      _municipalityController.clear();
                      _barangayController.clear();
                    });
                  },
                ),
                verticalSpace(20.h),

                // Province Field - Only show if region is selected
                if (selectedRegion != null) ...[
                  _buildResponsiveDropdownField(
                    'Province',
                    'Select Province',
                    _provinceController,
                    AddressData.getProvincesForRegion(selectedRegion!),
                    validator: UIFormValidators.provinceValidator(context),
                    onChanged: (value) {
                      setState(() {
                        selectedProvince = value;
                        selectedMunicipality = null;
                        _municipalityController.clear();
                        _barangayController.clear();
                      });
                    },
                  ),
                  verticalSpace(20.h),
                ],

                // Municipality Field - Only show if province is selected
                if (selectedProvince != null) ...[
                  _buildResponsiveDropdownField(
                    'Municipality',
                    'Select Municipality',
                    _municipalityController,
                    AddressData.getMunicipalitiesForProvince(selectedProvince!),
                    validator: UIFormValidators.municipalityValidator(context),
                    onChanged: (value) {
                      setState(() {
                        selectedMunicipality = value;
                        _barangayController.clear();
                      });
                    },
                  ),
                  verticalSpace(20.h),
                ],

                // Barangay Field - Only show if municipality is selected
                if (selectedMunicipality != null) ...[
                  _buildInputField(
                    'Barangay',
                    'Enter your barangay',
                    _barangayController,
                    validator: UIFormValidators.barangayValidator(context),
                  ),
                  verticalSpace(20.h),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.all(kAppMediumPadding),
      child: Row(
        children: [
          if (!_isEditing) ...[
            Expanded(
              child: CustomButton(
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
                text: 'Edit Profile',
              ),
            ),
          ] else ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : () {
                  setState(() {
                    _isEditing = false;
                    _loadUserData(); // Reset to original values
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: kAppMediumPadding),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  side: BorderSide(color: Colors.grey[400]!),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(width: kAppSmallGap),
            Expanded(
              child: _isLoading 
                ? Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: Center(
                      child: Text(
                        'Saving...',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                : CustomButton(
                    onPressed: () => _saveProfile(),
                    text: 'Save',
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    print('🔍 _saveProfile called');
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

        try {
          final state = context.read<AuthenticationBloc>().state;
          print('🔍 Current auth state: ${state.status}');
          print('🔍 Current user: ${state.user?.username}');
          
          if (state.user != null) {
            // Check if profile update is already in progress
            if (state.status == AuthenticationStatus.loading) {
              print('🚨 Profile update already in progress');
              setState(() {
                _isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(S.of(context).profile_update_in_progress),
                  backgroundColor: Colors.orange,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              );
              return;
            }

            // Create structured address object (same as registration)
            final address = {
              'region': _regionController.text.trim(),
              'province': _provinceController.text.trim(),
              'municipality': _municipalityController.text.trim(),
              'barangay': _barangayController.text.trim(),
            };
            
            // Combine first and last name
            final fullName = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'.trim();
            
            print('🔍 Created address object: $address');
            print('🔍 Address type: ${address.runtimeType}');
            print('🔍 Full name: $fullName');

            // Dispatch update profile event - let the backend handle authentication
            print('🔍 Dispatching UpdateProfileEvent...');
            context.read<AuthenticationBloc>().add(
              UpdateProfileEvent(
                userId: state.user!.id,
                fullName: fullName,
                contactNumber: _contactNumberController.text.trim(),
                address: address,
              ),
            );

          // Listen for the result with timeout
          bool resultReceived = false;
          await for (final authState in context.read<AuthenticationBloc>().stream) {
            if (authState.status == AuthenticationStatus.authenticated && 
                authState.message == S.of(context).profile_updated_successfully) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(S.of(context).profile_updated_successfully),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              );
              
              setState(() {
                _isEditing = false;
                _isLoading = false;
              });
              resultReceived = true;
              break;
            } else if (authState.status == AuthenticationStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(authState.message ?? 'Failed to update profile'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              );
              
              setState(() {
                _isLoading = false;
              });
              resultReceived = true;
              break;
            }
          }

          // If no result received after timeout, show error
          if (!resultReceived) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(S.of(context).request_timed_out),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            );
          }
        }
      } catch (e) {
        print("🚨 Profile update error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).failed_to_update_profile(e.toString())),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
        
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  // Input field builder (matching registration form)
  Widget _buildInputField(
    String label,
    String hint,
    TextEditingController controller, {
    bool isMultiline = false,
    bool showPHPrefix = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.bodyLarge?.copyWith(fontSize: 16.sp, fontWeight: FontWeight.w600)),
        SizedBox(height: 5.h),
        TextFormField(
          controller: controller,
          maxLines: isMultiline ? 3 : 1,
          keyboardType: showPHPrefix ? TextInputType.phone : keyboardType,
          style: textTheme.bodyMedium?.copyWith(fontSize: 16.sp),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white.withOpacity(0.8),
            hintStyle: TextStyle(
              color: const Color.fromARGB(122, 43, 70, 37),
              fontSize: 16.sp,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            errorStyle: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.red.shade700,
            ),
            errorMaxLines: 2,
            prefixIcon:
                showPHPrefix
                    ? Padding(
                      padding: const EdgeInsets.only(left: 10.0, top: 1.5),
                      child: Text(
                        '+63',
                        style: textTheme.bodyMedium?.copyWith(fontSize: 16.sp),
                      ),
                    )
                    : null,
            prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
          ),
          validator: validator,
        ),
      ],
    );
  }

  // Dropdown field builder (matching registration form)
  Widget _buildResponsiveDropdownField(
    String label,
    String hint,
    TextEditingController controller,
    List<String> options, {
    String? Function(String?)? validator,
    Function(String?)? onChanged,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.bodyLarge?.copyWith(fontSize: 16.sp, fontWeight: FontWeight.w600)),
        SizedBox(height: 5.h),
        DropdownButtonFormField<String>(
          value: controller.text.isEmpty ? null : controller.text,
          isExpanded: true, // Prevent overflow
          menuMaxHeight: 300.h, // Limit dropdown height
          dropdownColor: Colors.white,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white.withOpacity(0.8),
            hintStyle: TextStyle(
              color: const Color.fromARGB(122, 43, 70, 37),
              fontSize: 16.sp,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            errorStyle: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.red.shade700,
            ),
            errorMaxLines: 2,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 16.h,
            ),
          ),
          items:
              options.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      option,
                      style: textTheme.bodyMedium?.copyWith(fontSize: 14.sp),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                );
              }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              controller.text = newValue;
              if (onChanged != null) {
                onChanged(newValue);
              }
            }
          },
          validator: validator,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _contactNumberController.dispose();
    _regionController.dispose();
    _provinceController.dispose();
    _municipalityController.dispose();
    _barangayController.dispose();
    super.dispose();
  }
}