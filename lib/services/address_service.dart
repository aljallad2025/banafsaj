import '../models/address.dart';
import 'api_service.dart';

class AddressService {
  static Future<List<Address>> list() async {
    final data = await ApiService.get('addresses.php');
    return List<Address>.from((data as List).map((a) => Address.fromJson(a)));
  }

  static Future<void> add({required String fullName, required String phone, required String city, String? district, required String street, String? postalCode, bool isDefault = false, String label = 'المنزل'}) async {
    await ApiService.post('addresses.php', {
      'full_name': fullName, 'phone': phone, 'city': city, 'district': district,
      'street': street, 'postal_code': postalCode, 'is_default': isDefault, 'label': label,
    });
  }

  static Future<void> delete(int id) async {
    await ApiService.delete('addresses.php', {'id': id});
  }
}
