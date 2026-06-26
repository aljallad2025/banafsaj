class Customer {
  final int id;
  final String name;
  final String firstName;
  final String? lastName;
  final String email;
  final String? phone;

  Customer({required this.id, required this.name, required this.firstName, this.lastName, required this.email, this.phone});

  factory Customer.fromJson(Map<String, dynamic> j) => Customer(
        id: j['id'],
        name: j['name'] ?? '',
        firstName: j['first_name'] ?? '',
        lastName: j['last_name'],
        email: j['email'] ?? '',
        phone: j['phone'],
      );
}
