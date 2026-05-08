enum UserRole {
  client('client'),
  prestataire('prestataire');

  const UserRole(this.value);

  final String value;

  static UserRole? fromValue(String value) {
    for (final role in UserRole.values) {
      if (role.value == value) return role;
    }
    return null;
  }
}
