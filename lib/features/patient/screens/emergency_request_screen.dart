// Enhanced Emergency Request Screen with Firestore integration
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/request_model.dart';
import '../../../services/firestore_service.dart';
import '../../../services/fcm_service.dart';
import '../../../providers/auth_provider.dart';

class EmergencyRequestScreen extends ConsumerStatefulWidget {
  const EmergencyRequestScreen({super.key});

  @override
  ConsumerState<EmergencyRequestScreen> createState() => _EmergencyRequestScreenState();
}

class _EmergencyRequestScreenState extends ConsumerState<EmergencyRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _symptomsController = TextEditingController();
  final _notesController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  final FCMService _fcmService = FCMService();
  
  Position? _currentPosition;
  String _locationAddress = 'جاري تحديد الموقع...';
  List<UserModel> _nearbyDoctors = [];
  UserModel? _selectedDoctor;
  bool _isLoading = false;
  bool _isLocationLoading = false;
  String _urgencyLevel = 'medium';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _symptomsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLocationLoading = true);
    
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationAddress = 'خدمات الموقع غير مفعلة';
          _isLocationLoading = false;
        });
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationAddress = 'تم رفض إذن الموقع';
            _isLocationLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationAddress = 'تم رفض إذن الموقع نهائياً';
          _isLocationLoading = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _locationAddress = 'الموقع: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
        _isLocationLoading = false;
      });

      // Fetch nearby doctors
      await _fetchNearbyDoctors();
    } catch (e) {
      setState(() {
        _locationAddress = 'خطأ في تحديد الموقع: $e';
        _isLocationLoading = false;
      });
    }
  }

  Future<void> _fetchNearbyDoctors() async {
    if (_currentPosition == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      final doctors = await _firestoreService.getNearbyDoctors(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        radiusKm: 50.0, // 50km radius
      );
      
      setState(() {
        _nearbyDoctors = doctors;
        if (doctors.isNotEmpty) {
          _selectedDoctor = doctors.first; // Auto-select closest doctor
        } else {
          _selectedDoctor = null; // Clear selection if no doctors
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _nearbyDoctors = [];
        _selectedDoctor = null;
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في جلب الأطباء القريبين: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitEmergencyRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى تحديد الموقع أولاً'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_selectedDoctor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار طبيب'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final currentUserAsync = ref.read(currentUserDataProvider);
      final currentUser = currentUserAsync.when(
        data: (user) => user,
        loading: () => null,
        error: (_, __) => null,
      );
      if (currentUser == null) {
        throw Exception('لم يتم العثور على بيانات المستخدم');
      }
      
      // Create emergency request
      final request = RequestModel(
        id: '', // Will be set by Firestore
        patientId: currentUser.uid,
        doctorId: _selectedDoctor!.uid,
        status: RequestStatus.pending,
        patientLocation: GeoPoint(_currentPosition!.latitude, _currentPosition!.longitude),
        patientAddress: _locationAddress,
        symptoms: _symptomsController.text.trim(),
        urgencyLevel: _urgencyLevel,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final requestId = await _firestoreService.createEmergencyRequest(request);
      
      // Send notification to doctor
      if (_selectedDoctor!.fcmToken != null) {
        await _fcmService.sendNotificationToUser(
          token: _selectedDoctor!.fcmToken!,
          title: 'طلب طوارئ جديد',
          body: 'لديك طلب طوارئ جديد من ${currentUser.name}',
          data: {
            'type': 'emergency_request',
            'requestId': requestId,
            'patientId': currentUser.uid,
            'patientName': currentUser.name,
          },
        );
      }
      
      if (!mounted) return;
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إرسال طلب الطوارئ بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Navigate to request tracking screen
      context.push('/patient/request-tracking/$requestId');
      
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في إرسال الطلب: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('طلب طوارئ'),
        backgroundColor: Colors.red[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Emergency Warning Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red[600], size: 24),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'هذا طلب طوارئ. سيتم إشعار أقرب طبيب متاح فوراً.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Location Card
              _buildLocationCard(),
              
              const SizedBox(height: 20),
              
              // Symptoms Input
              _buildSymptomsCard(),
              
              const SizedBox(height: 20),
              
              // Urgency Level
              _buildUrgencyCard(),
              
              const SizedBox(height: 20),
              
              // Nearby Doctors
              if (_isLoading)
                _buildLoadingDoctorsCard()
              else if (_nearbyDoctors.isNotEmpty) 
                _buildNearbyDoctorsCard()
              else if (_currentPosition != null) // FIXED: Show message when no available doctors
                _buildNoAvailableDoctorsCard(),
              
              const SizedBox(height: 30),
              
              // Submit Button
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.location_on, color: Colors.red, size: 24),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'الموقع الحالي',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLocationLoading)
            const Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('جاري تحديد الموقع...'),
              ],
            )
          else
            Text(
              _locationAddress,
              style: TextStyle(
                fontSize: 16,
                color: _currentPosition != null ? Colors.green[700] : Colors.red[700],
              ),
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.refresh),
              label: const Text('تحديث الموقع'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.medical_services, color: Colors.blue, size: 24),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'وصف الأعراض',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _symptomsController,
            decoration: const InputDecoration(
              hintText: 'اكتب وصفاً مفصلاً للأعراض والحالة الطارئة...',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(16),
            ),
            maxLines: 4,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'يرجى وصف الأعراض';
              }
              if (value.trim().length < 10) {
                return 'يرجى كتابة وصف أكثر تفصيلاً (على الأقل 10 أحرف)';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUrgencyCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.priority_high, color: Colors.orange, size: 24),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'مستوى الأولوية',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              RadioListTile<String>(
                title: const Text('منخفض - حالة غير عاجلة'),
                subtitle: const Text('يمكن الانتظار لبعض الوقت'),
                value: 'low',
                groupValue: _urgencyLevel,
                onChanged: (value) => setState(() => _urgencyLevel = value!),
                contentPadding: EdgeInsets.zero,
              ),
              RadioListTile<String>(
                title: const Text('متوسط - حالة تحتاج عناية'),
                subtitle: const Text('يفضل الحصول على المساعدة قريباً'),
                value: 'medium',
                groupValue: _urgencyLevel,
                onChanged: (value) => setState(() => _urgencyLevel = value!),
                contentPadding: EdgeInsets.zero,
              ),
              RadioListTile<String>(
                title: const Text('عالي - حالة طوارئ'),
                subtitle: const Text('تحتاج تدخل طبي فوري'),
                value: 'high',
                groupValue: _urgencyLevel,
                onChanged: (value) => setState(() => _urgencyLevel = value!),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyDoctorsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.local_hospital, color: Colors.green, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'الأطباء القريبون (${_nearbyDoctors.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _nearbyDoctors.length,
            itemBuilder: (context, index) {
              final doctor = _nearbyDoctors[index];
              final isSelected = _selectedDoctor?.uid == doctor.uid;
              final distance = _currentPosition != null && doctor.location != null
                  ? _calculateDistance(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                      doctor.location!.latitude,
                      doctor.location!.longitude,
                    )
                  : 0.0;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? Colors.green : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: isSelected ? Colors.green[50] : null,
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green[100],
                    backgroundImage: doctor.profileImage != null
                        ? NetworkImage(doctor.profileImage!)
                        : null,
                    child: doctor.profileImage == null
                        ? Text(
                            doctor.name.substring(0, 1),
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  title: Text(
                    'د. ${doctor.name}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (doctor.specialization != null)
                        Text(doctor.specialization!),
                      Text('المسافة: ${distance.toStringAsFixed(1)} كم'),
                      if (doctor.rating != null)
                        Row(
                          children: [
                            Icon(Icons.star, size: 16, color: Colors.amber[600]),
                            const SizedBox(width: 4),
                            Text('${doctor.rating!.toStringAsFixed(1)}'),
                          ],
                        ),
                    ],
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: Colors.green[600])
                      : null,
                  onTap: () => setState(() => _selectedDoctor = doctor),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: (_isLoading || _nearbyDoctors.isEmpty || _selectedDoctor == null) ? null : _submitEmergencyRequest, // FIXED: Disable if no doctors available or no doctor selected
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[600],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: _isLoading
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('جاري الإرسال...'),
                ],
              )
            : _nearbyDoctors.isEmpty
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.warning, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'لا يوجد أطباء متاحون',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.emergency, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'إرسال طلب الطوارئ',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
      ),
    );
  }

  // Loading doctors card
  Widget _buildLoadingDoctorsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'جاري البحث عن الأطباء المتاحين...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // FIXED: Widget for when no available doctors are found
  Widget _buildNoAvailableDoctorsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.local_hospital_outlined,
            size: 64,
            color: Colors.orange[600],
          ),
          const SizedBox(height: 16),
          Text(
            'لا يوجد أطباء متاحون حالياً',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.orange[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'جميع الأطباء في منطقتك غير متاحين الآن. يرجى المحاولة لاحقاً أو الاتصال بالطوارئ مباشرة.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _fetchNearbyDoctors,
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة البحث'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Call emergency services
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('اتصل بـ 123 للطوارئ الطبية'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                  icon: const Icon(Icons.phone),
                  label: const Text('اتصال طوارئ'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000; // Convert to km
  }
}
