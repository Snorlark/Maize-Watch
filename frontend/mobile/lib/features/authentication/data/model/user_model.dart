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
    return UserModel(
      id:
          json['_id'] as String? ??
          json['id'] as String, // Handle both _id and id
      username: json['username'] as String,
      fullName: json['fullName'] as String,
      contactNumber: json['contactNumber'] as String,
      address: _parseAddress(
        json['address'],
      ), // Handle both string and object address
      role: json['role'] as String,
      password:
          json['password']
              as String?, // Password is often not returned from backend for security
    );
  }

  static Map<String, dynamic> _parseAddress(dynamic address) {
    if (address is Map<String, dynamic>) {
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
