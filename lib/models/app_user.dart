class AppUser {
  final String id;
  final String? email;
  final String? name;
  final String role;

  AppUser({required this.id, this.email, this.name, this.role = 'user'});

  bool get isAdmin => role == 'admin';
}
