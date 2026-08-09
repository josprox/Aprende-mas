class UserModel {
  final int id;
  final String? firstName;
  final String? lastName;
  final String username;
  final String email;
  final String? phone;

  UserModel({
    required this.id,
    this.firstName,
    this.lastName,
    required this.username,
    required this.email,
    this.phone,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      firstName: json['first_name'],
      lastName: json['last_name'],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'username': username,
      'email': email,
      'phone': phone,
    };
  }

  String get fullName {
    if (firstName != null && firstName!.isNotEmpty) {
      if (lastName != null && lastName!.isNotEmpty) {
        return '$firstName $lastName';
      }
      return firstName!;
    }
    return username;
  }
}

class AuthResponse {
  final bool success;
  final String? token;
  final UserModel? user;
  final String? message;
  final bool requires2FA;
  final String? challengeToken;

  AuthResponse({
    required this.success,
    this.token,
    this.user,
    this.message,
    this.requires2FA = false,
    this.challengeToken,
  });
}
