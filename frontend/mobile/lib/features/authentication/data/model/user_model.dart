import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.username,
    required super.fullName,
    required super.contactNumber,
    required super.address,
    required super.role,
    super.password, // Make password optional since it's not always returned
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    print('🔍 UserModel.fromJson called with: $json');
    
    try {
      print('🔍 Parsing id: ${json['_id']} (type: ${json['_id'].runtimeType})');
      final id = json['_id'] as String? ?? json['id'] as String;
      print('🔍 Parsed id: $id');
      
      print('🔍 Parsing username: ${json['username']} (type: ${json['username'].runtimeType})');
      final username = json['username'] as String? ?? '';
      print('🔍 Parsed username: $username');
      
      print('🔍 Parsing fullName: ${json['fullName']} (type: ${json['fullName'].runtimeType})');
      final fullName = json['fullName'] as String? ?? '';
      print('🔍 Parsed fullName: $fullName');
      
      print('🔍 Parsing contactNumber: ${json['contactNumber']} (type: ${json['contactNumber'].runtimeType})');
      final contactNumber = json['contactNumber'] as String? ?? '';
      print('🔍 Parsed contactNumber: $contactNumber');
      
      print('🔍 Parsing address: ${json['address']} (type: ${json['address']?.runtimeType})');
      final address = _parseAddress(json['address']);
      print('🔍 Parsed address: $address');
      
      print('🔍 Parsing role: ${json['role']} (type: ${json['role'].runtimeType})');
      final role = json['role'] as String? ?? 'user';
      print('🔍 Parsed role: $role');
      
      print('🔍 Parsing password: ${json['password']} (type: ${json['password']?.runtimeType})');
      final password = json['password'] as String?;
      print('🔍 Parsed password: $password');
      
      print('🔍 Creating UserModel...');
      final userModel = UserModel(
        id: id,
        username: username,
        fullName: fullName,
        contactNumber: contactNumber,
        address: address,
        role: role,
        password: password,
      );
      print('🔍 UserModel created successfully: ${userModel.username}');
      return userModel;
    } catch (e, stackTrace) {
      print('🚨 Error in UserModel.fromJson: $e');
      print('🚨 Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Map<String, dynamic> _parseAddress(dynamic address) {
    if (address == null) {
      return {'region': '', 'province': '', 'municipality': '', 'barangay': ''};
    } else if (address is Map<String, dynamic>) {
      return address;
    } else if (address is String) {
      // Convert legacy string address to structured format
      return {
        'region': '',
        'province': '',
        'municipality': '',
        'barangay': address, // Store string in barangay field as fallback
      };
    }
    return {'region': '', 'province': '', 'municipality': '', 'barangay': ''};
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id, // Include id in JSON if needed
      'username': username,
      'fullName': fullName,
      'contactNumber': contactNumber,
      'address': address,
      'role': role,
      if (password != null)
        'password': password, // Only include password if it exists
    };
  }
}
