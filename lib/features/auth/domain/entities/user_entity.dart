class UserEntity {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String status;

  UserEntity({required this.id, required this.name, required this.email, this.phone = '', required this.role, this.status = ''});
}