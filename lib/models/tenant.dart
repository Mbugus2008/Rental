class Tenant {
  Tenant({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.notes,
  });

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String? notes;
}
