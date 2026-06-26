import 'package:flutter/material.dart';
import '../../models/address.dart';
import '../../services/address_service.dart';
import '../../utils/theme.dart';
import '../../widgets/toast.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});
  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  List<Address> _addresses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      _addresses = await AddressService.list();
    } catch (_) {}
    setState(() => _loading = false);
  }

  void _showAddDialog() {
    final nameC = TextEditingController();
    final phoneC = TextEditingController();
    final cityC = TextEditingController();
    final districtC = TextEditingController();
    final streetC = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('إضافة عنوان جديد', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              TextField(controller: nameC, decoration: const InputDecoration(labelText: 'الاسم الكامل')),
              const SizedBox(height: 10),
              TextField(controller: phoneC, decoration: const InputDecoration(labelText: 'الجوال')),
              const SizedBox(height: 10),
              TextField(controller: cityC, decoration: const InputDecoration(labelText: 'المدينة')),
              const SizedBox(height: 10),
              TextField(controller: districtC, decoration: const InputDecoration(labelText: 'الحي')),
              const SizedBox(height: 10),
              TextField(controller: streetC, decoration: const InputDecoration(labelText: 'العنوان التفصيلي')),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await AddressService.add(fullName: nameC.text, phone: phoneC.text, city: cityC.text, district: districtC.text, street: streetC.text);
                      if (ctx.mounted) Navigator.pop(ctx);
                      _load();
                      ToastUtil.show('تم إضافة العنوان');
                    } catch (e) {
                      ToastUtil.show('$e', isError: true);
                    }
                  },
                  child: const Text('حفظ العنوان'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('عناويني'), actions: [IconButton(icon: const Icon(Icons.add), onPressed: _showAddDialog)]),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : _addresses.isEmpty
              ? const Center(child: Text('لا توجد عناوين محفوظة', style: TextStyle(color: AppColors.muted)))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _addresses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final a = _addresses[i];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(a.fullName, style: const TextStyle(fontWeight: FontWeight.w700)),
                                Text('${a.city} — ${a.street}', style: const TextStyle(color: AppColors.muted, fontSize: 12.5)),
                                Text(a.phone, style: const TextStyle(color: AppColors.muted, fontSize: 12.5)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.red),
                            onPressed: () async {
                              await AddressService.delete(a.id);
                              _load();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
