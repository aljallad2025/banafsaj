import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/order_service.dart';
import '../../services/address_service.dart';
import '../../services/config_service.dart';
import '../../models/address.dart';
import '../../utils/theme.dart';
import '../../widgets/toast.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  List<Address> _addresses = [];
  int? _selectedAddressId;
  bool _useNewAddress = false;
  bool _loading = true;
  bool _placing = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _streetController = TextEditingController();
  final _notesController = TextEditingController();
  final _couponController = TextEditingController();

  double _shippingCost = 0;
  double _discount = 0;
  String _paymentMethod = 'cod';
  List<Map<String, dynamic>> _shippingCompanies = [];
  int? _selectedShippingId;

  static const cities = ['الرياض','جدة','مكة المكرمة','المدينة المنورة','الدمام','الخبر','الظهران','تبوك','أبها','نجران','جازان','حائل','القصيم','الطائف','بريدة'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        AddressService.list(),
        ConfigService.get(),
      ]);
      _addresses = results[0] as List<Address>;
      final config = results[1] as StoreConfig;
      final cart = context.read<CartProvider>();
      _shippingCost = (config.freeShippingMin > 0 && cart.subtotal >= config.freeShippingMin) ? 0 : config.defaultShippingCost;
      _shippingCompanies = config.shippingCompanies;
      if (_addresses.isNotEmpty) {
        _selectedAddressId = _addresses.firstWhere((a) => a.isDefault, orElse: () => _addresses.first).id;
      } else {
        _useNewAddress = true;
      }
    } catch (_) {
      _useNewAddress = true;
    }
    setState(() => _loading = false);
  }

  Future<void> _applyCoupon() async {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;
    final cart = context.read<CartProvider>();
    try {
      final result = await OrderService.validateCoupon(code, cart.subtotal);
      setState(() => _discount = (result['discount'] as num).toDouble());
      ToastUtil.show('✓ ${result['discount_formatted']} خصم تم تطبيقه');
    } catch (e) {
      ToastUtil.show('$e', isError: true);
    }
  }

  Future<void> _placeOrder() async {
    Map<String, dynamic>? shippingAddress;
    int? addressId;

    if (_useNewAddress || _addresses.isEmpty) {
      if (_nameController.text.isEmpty || _phoneController.text.isEmpty || _cityController.text.isEmpty || _streetController.text.isEmpty) {
        return ToastUtil.show('يرجى تعبئة جميع الحقول المطلوبة', isError: true);
      }
      shippingAddress = {
        'full_name': _nameController.text, 'phone': _phoneController.text,
        'city': _cityController.text, 'district': _districtController.text,
        'street': _streetController.text, 'save': true,
      };
    } else {
      addressId = _selectedAddressId;
    }

    setState(() => _placing = true);
    try {
      final selectedCompany = _shippingCompanies.isNotEmpty
          ? _shippingCompanies.firstWhere((sc) => sc['id'] == (_selectedShippingId ?? _shippingCompanies.first['id']), orElse: () => _shippingCompanies.first)['name']
          : null;
      final result = await OrderService.placeOrder(
        addressId: addressId, shippingAddress: shippingAddress,
        shippingCost: _shippingCost, shippingCompany: selectedCompany, paymentMethod: _paymentMethod,
        couponCode: _couponController.text.trim().isNotEmpty ? _couponController.text.trim() : null,
        notes: _notesController.text,
      );
      if (!mounted) return;
      context.read<CartProvider>().clearLocal();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => OrderSuccessScreen(orderNumber: result['order_number'])));
    } catch (e) {
      ToastUtil.show('$e', isError: true);
    } finally {
      setState(() => _placing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final total = cart.subtotal - _discount + _shippingCost;

    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.gold)));

    return Scaffold(
      appBar: AppBar(title: const Text('إتمام الطلب')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('عنوان التوصيل', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 12),
            ..._addresses.map((a) => RadioListTile<int>(
                  value: a.id, groupValue: _useNewAddress ? -1 : _selectedAddressId,
                  onChanged: (v) => setState(() { _selectedAddressId = v; _useNewAddress = false; }),
                  title: Text(a.fullName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                  subtitle: Text('${a.city} — ${a.street}', style: const TextStyle(fontSize: 12)),
                  activeColor: AppColors.gold,
                  contentPadding: EdgeInsets.zero,
                )),
            if (_addresses.isNotEmpty)
              RadioListTile<int>(
                value: -1, groupValue: _useNewAddress ? -1 : _selectedAddressId,
                onChanged: (v) => setState(() => _useNewAddress = true),
                title: const Text('+ إضافة عنوان جديد', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                activeColor: AppColors.gold,
                contentPadding: EdgeInsets.zero,
              ),
            if (_useNewAddress || _addresses.isEmpty) ...[
              const SizedBox(height: 8),
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'الاسم الكامل *')),
              const SizedBox(height: 10),
              TextField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'رقم الجوال *')),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'المدينة *'),
                items: cities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => _cityController.text = v ?? '',
              ),
              const SizedBox(height: 10),
              TextField(controller: _districtController, decoration: const InputDecoration(labelText: 'الحي')),
              const SizedBox(height: 10),
              TextField(controller: _streetController, decoration: const InputDecoration(labelText: 'العنوان التفصيلي *')),
            ],
            const SizedBox(height: 24),
            const Text('طريقة الشحن', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 8),
            if (_shippingCost == 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(color: AppColors.green.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
                child: const Text('🚚 شحن مجاني لهذا الطلب', style: TextStyle(color: AppColors.green, fontWeight: FontWeight.w700, fontSize: 13)),
              )
            else if (_shippingCompanies.isEmpty)
              Text('تكلفة الشحن: ${_shippingCost.toStringAsFixed(2)} ر.س', style: const TextStyle(color: AppColors.muted, fontSize: 13.5))
            else
              ..._shippingCompanies.map((sc) => RadioListTile<int>(
                    value: sc['id'], groupValue: _selectedShippingId ?? _shippingCompanies.first['id'],
                    onChanged: (v) => setState(() => _selectedShippingId = v),
                    title: Text(sc['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                    activeColor: AppColors.gold,
                    contentPadding: EdgeInsets.zero,
                  )),
            const SizedBox(height: 24),
            const Text('ملاحظات (اختياري)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 10),
            TextField(controller: _notesController, maxLines: 2, decoration: const InputDecoration(hintText: 'أي تعليمات خاصة للتوصيل...')),
            const SizedBox(height: 24),
            const Text('كود الخصم', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: TextField(controller: _couponController, decoration: const InputDecoration(hintText: 'أدخل الكود'))),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: _applyCoupon, child: const Text('تطبيق')),
            ]),
            const SizedBox(height: 24),
            const Text('طريقة الدفع', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            RadioListTile<String>(value: 'cod', groupValue: _paymentMethod, onChanged: (v) => setState(() => _paymentMethod = v!), title: const Text('💵 الدفع عند الاستلام'), activeColor: AppColors.gold, contentPadding: EdgeInsets.zero),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.off, borderRadius: BorderRadius.circular(14)),
              child: Column(children: [
                _summaryRow('المجموع الفرعي', cart.subtotalFormatted),
                if (_discount > 0) _summaryRow('الخصم', '-${_discount.toStringAsFixed(2)} ر.س', color: AppColors.green),
                _summaryRow('الشحن', _shippingCost > 0 ? '${_shippingCost.toStringAsFixed(2)} ر.س' : 'مجاناً'),
                const Divider(),
                _summaryRow('الإجمالي', '${total.toStringAsFixed(2)} ر.س', bold: true),
              ]),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _placing ? null : _placeOrder,
                child: _placing ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('تأكيد الطلب'),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false, Color? color}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: TextStyle(fontSize: bold ? 16 : 13.5, fontWeight: bold ? FontWeight.w800 : FontWeight.w500)),
          Text(value, style: TextStyle(fontSize: bold ? 18 : 13.5, fontWeight: bold ? FontWeight.w800 : FontWeight.w600, color: color ?? (bold ? AppColors.gold : AppColors.text))),
        ]),
      );
}
