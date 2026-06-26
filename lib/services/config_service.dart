import 'api_service.dart';

class StoreConfig {
  final String siteName;
  final String? siteTagline;
  final String? logo;
  final String? whatsapp;
  final String? phone;
  final String? email;
  final double freeShippingMin;
  final double defaultShippingCost;
  final List<Map<String, dynamic>> shippingCompanies;

  StoreConfig({required this.siteName, this.siteTagline, this.logo, this.whatsapp, this.phone, this.email, required this.freeShippingMin, required this.defaultShippingCost, required this.shippingCompanies});

  factory StoreConfig.fromJson(Map<String, dynamic> j) => StoreConfig(
        siteName: j['site_name'] ?? 'بنفسج ستور',
        siteTagline: j['site_tagline'],
        logo: j['logo'],
        whatsapp: j['whatsapp'],
        phone: j['phone'],
        email: j['email'],
        freeShippingMin: (j['free_shipping_min'] ?? 0).toDouble(),
        defaultShippingCost: (j['default_shipping_cost'] ?? 0).toDouble(),
        shippingCompanies: List<Map<String, dynamic>>.from(j['shipping_companies'] ?? []),
      );
}

class ConfigService {
  static Future<StoreConfig> get() async {
    final data = await ApiService.get('config.php');
    return StoreConfig.fromJson(data);
  }

  static Future<List<Map<String, dynamic>>> slides() async {
    final data = await ApiService.get('slider.php');
    return List<Map<String, dynamic>>.from(data);
  }
}
