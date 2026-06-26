class Address {
  final int id;
  final String label;
  final String fullName;
  final String phone;
  final String city;
  final String? district;
  final String street;
  final String? postalCode;
  final bool isDefault;

  Address({required this.id, required this.label, required this.fullName, required this.phone, required this.city, this.district, required this.street, this.postalCode, this.isDefault = false});

  factory Address.fromJson(Map<String, dynamic> j) => Address(
        id: j['id'],
        label: j['label'] ?? 'المنزل',
        fullName: j['full_name'] ?? '',
        phone: j['phone'] ?? '',
        city: j['city'] ?? '',
        district: j['district'],
        street: j['street'] ?? '',
        postalCode: j['postal_code'],
        isDefault: (j['is_default'] ?? 0) == 1,
      );
}
