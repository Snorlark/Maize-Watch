import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String username;
  final String fullName;
  final String contactNumber; // Make sure this matches your backend field
  final Map<String, dynamic> address;
  final String? password;
  final String role;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.username,
    this.password,
    required this.fullName,
    required this.contactNumber,
    required this.address,
    required this.role,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    username,
    fullName,
    contactNumber,
    address,
    role,
    password, // Include password (can be null)
  ];
}
