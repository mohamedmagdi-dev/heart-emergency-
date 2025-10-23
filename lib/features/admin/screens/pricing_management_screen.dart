// Pricing management screen for admins and technical team
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/pricing_service.dart';
import '../../../providers/auth_provider.dart';

class PricingManagementScreen extends ConsumerStatefulWidget {
  const PricingManagementScreen({super.key});

  @override
  ConsumerState<PricingManagementScreen> createState() => _PricingManagementScreenState();
}

class _PricingManagementScreenState extends ConsumerState<PricingManagementScreen> {
  final PricingService _pricingService = PricingService();
  final PageController _pageController = PageController();
  
  PricingConfig? _defaultPricing;
  List<DoctorPricingInfo> _doctorPricingList = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPricingData();
  }

  Future<void> _loadPricingData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final defaultPricing = await _pricingService.getDefaultPricing();
      final doctorPricingList = await _pricingService.getAllDoctorPricing();
      
      setState(() {
        _defaultPricing = defaultPricing;
        _doctorPricingList = doctorPricingList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة التسعير'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPricingData,
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 60),
                      const SizedBox(height: 20),
                      Text(_errorMessage!),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _loadPricingData,
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                )
              : PageView(
                  controller: _pageController,
                  children: [
                    _buildDefaultPricingTab(),
                    _buildDoctorPricingTab(),
                  ],
                ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _pageController.hasClients ? _pageController.page?.round() ?? 0 : 0,
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'التسعير الافتراضي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'تسعير الأطباء',
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultPricingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'التسعير الافتراضي',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (_defaultPricing != null) ...[
                    _buildPricingInfo(_defaultPricing!),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _showEditDefaultPricingDialog(),
                      child: const Text('تعديل التسعير الافتراضي'),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'معلومات التسعير',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '• السعر الأساسي: المبلغ الثابت لكل طلب\n'
                    '• السعر لكل كيلومتر: المبلغ المضاف للمسافة\n'
                    '• السعر لكل دقيقة: المبلغ المضاف للوقت\n'
                    '• السعر الأدنى: أقل مبلغ يمكن تحصيله\n'
                    '• السعر الأقصى: أعلى مبلغ يمكن تحصيله',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorPricingTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'تسعير الأطباء',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: _showAddDoctorPricingDialog,
                icon: const Icon(Icons.add),
                label: const Text('إضافة تسعير طبيب'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _doctorPricingList.isEmpty
              ? const Center(
                  child: Text('لا يوجد تسعير مخصص للأطباء'),
                )
              : ListView.builder(
                  itemCount: _doctorPricingList.length,
                  itemBuilder: (context, index) {
                    final doctorPricing = _doctorPricingList[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(doctorPricing.doctorName),
                        subtitle: Text('السعر الأساسي: ${doctorPricing.pricing.basePrice} ${doctorPricing.pricing.currency}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showEditDoctorPricingDialog(doctorPricing),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _showDeleteDoctorPricingDialog(doctorPricing),
                            ),
                          ],
                        ),
                        onTap: () => _showDoctorPricingDetails(doctorPricing),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPricingInfo(PricingConfig pricing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('السعر الأساسي', '${pricing.basePrice} ${pricing.currency}'),
        _buildInfoRow('السعر لكل كيلومتر', '${pricing.pricePerKm} ${pricing.currency}'),
        _buildInfoRow('السعر لكل دقيقة', '${pricing.pricePerMinute} ${pricing.currency}'),
        _buildInfoRow('السعر الأدنى', '${pricing.minimumPrice} ${pricing.currency}'),
        _buildInfoRow('السعر الأقصى', '${pricing.maximumPrice} ${pricing.currency}'),
        _buildInfoRow('العملة', pricing.currency),
        _buildInfoRow('الحالة', pricing.isActive ? 'نشط' : 'غير نشط'),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: Colors.blue)),
        ],
      ),
    );
  }

  void _showEditDefaultPricingDialog() {
    if (_defaultPricing == null) return;

    final controllers = {
      'basePrice': TextEditingController(text: _defaultPricing!.basePrice.toString()),
      'pricePerKm': TextEditingController(text: _defaultPricing!.pricePerKm.toString()),
      'pricePerMinute': TextEditingController(text: _defaultPricing!.pricePerMinute.toString()),
      'minimumPrice': TextEditingController(text: _defaultPricing!.minimumPrice.toString()),
      'maximumPrice': TextEditingController(text: _defaultPricing!.maximumPrice.toString()),
      'currency': TextEditingController(text: _defaultPricing!.currency),
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل التسعير الافتراضي'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField('السعر الأساسي', controllers['basePrice']!, TextInputType.number),
              _buildTextField('السعر لكل كيلومتر', controllers['pricePerKm']!, TextInputType.number),
              _buildTextField('السعر لكل دقيقة', controllers['pricePerMinute']!, TextInputType.number),
              _buildTextField('السعر الأدنى', controllers['minimumPrice']!, TextInputType.number),
              _buildTextField('السعر الأقصى', controllers['maximumPrice']!, TextInputType.number),
              _buildTextField('العملة', controllers['currency']!, TextInputType.text),
              SwitchListTile(
                title: const Text('نشط'),
                value: _defaultPricing!.isActive,
                onChanged: (value) {
                  setState(() {
                    _defaultPricing = PricingConfig(
                      basePrice: _defaultPricing!.basePrice,
                      pricePerKm: _defaultPricing!.pricePerKm,
                      pricePerMinute: _defaultPricing!.pricePerMinute,
                      minimumPrice: _defaultPricing!.minimumPrice,
                      maximumPrice: _defaultPricing!.maximumPrice,
                      currency: _defaultPricing!.currency,
                      isActive: value,
                    );
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final newPricing = PricingConfig(
                  basePrice: double.parse(controllers['basePrice']!.text),
                  pricePerKm: double.parse(controllers['pricePerKm']!.text),
                  pricePerMinute: double.parse(controllers['pricePerMinute']!.text),
                  minimumPrice: double.parse(controllers['minimumPrice']!.text),
                  maximumPrice: double.parse(controllers['maximumPrice']!.text),
                  currency: controllers['currency']!.text,
                  isActive: _defaultPricing!.isActive,
                );

                final currentUser = ref.read(currentUserDataProvider).maybeWhen(
                  data: (user) => user,
                  orElse: () => null,
                );

                if (currentUser != null) {
                  await _pricingService.updateDefaultPricing(
                    pricing: newPricing,
                    adminId: currentUser.uid,
                  );

                  setState(() {
                    _defaultPricing = newPricing;
                  });

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم تحديث التسعير الافتراضي بنجاح'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('خطأ في تحديث التسعير: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, TextInputType type) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  void _showAddDoctorPricingDialog() {
    // Implementation for adding doctor pricing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('إضافة تسعير طبيب - سيتم تنفيذها قريباً')),
    );
  }

  void _showEditDoctorPricingDialog(DoctorPricingInfo doctorPricing) {
    // Implementation for editing doctor pricing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تعديل تسعير طبيب - سيتم تنفيذها قريباً')),
    );
  }

  void _showDeleteDoctorPricingDialog(DoctorPricingInfo doctorPricing) {
    // Implementation for deleting doctor pricing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('حذف تسعير طبيب - سيتم تنفيذها قريباً')),
    );
  }

  void _showDoctorPricingDetails(DoctorPricingInfo doctorPricing) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تفاصيل تسعير ${doctorPricing.doctorName}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPricingInfo(doctorPricing.pricing),
              if (doctorPricing.lastUpdated != null) ...[
                const SizedBox(height: 16),
                Text(
                  'آخر تحديث: ${doctorPricing.lastUpdated!.toString().split('.')[0]}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
