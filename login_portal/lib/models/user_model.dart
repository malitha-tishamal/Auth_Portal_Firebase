class AppUser {
  final String uid;
  final String email;
  final String name;
  final String nic;
  final String mobile;
  final String role; // 'admin' or 'user'

  AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.nic,
    required this.mobile,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'nic': nic,
      'mobile': mobile,
      'role': role,
    };
  }

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      nic: map['nic'] ?? '',
      mobile: map['mobile'] ?? '',
      role: map['role'] ?? 'user',
    );
  }
}