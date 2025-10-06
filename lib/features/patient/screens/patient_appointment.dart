import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';
import '../../../services/doctor_request_service.dart';
import '../../../services/firestore_service.dart';

class AppointmentBookingPage extends StatefulWidget {
  const AppointmentBookingPage({super.key});

  @override
  State<AppointmentBookingPage> createState() => _AppointmentBookingPageState();
}

class _AppointmentBookingPageState extends State<AppointmentBookingPage> {
  String? _selectedDoctorId;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _requestMessageController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();
  final DoctorRequestService _doctorRequestService = DoctorRequestService();
  
  List<UserModel> _doctors = [];
  bool _isLoading = false;
  bool _isRequesting = false;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _reasonController.dispose();
    _requestMessageController.dispose();
    super.dispose();
  }

  Future<void> _loadDoctors() async {
    setState(() => _isLoading = true);
    try {
      final doctors = await _firestoreService.getVerifiedDoctors();
      setState(() {
        _doctors = doctors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل الأطباء: $e')),
        );
      }
    }
  }

  Future<void> _requestDoctor(String doctorId) async {
    if (_requestMessageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى كتابة رسالة للطبيب')),
      );
      return;
    }

    setState(() => _isRequesting = true);
    try {
      await _doctorRequestService.createDoctorRequest(
        doctorId: doctorId,
        message: _requestMessageController.text.trim(),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إرسال الطلب بنجاح')),
        );
        _requestMessageController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في إرسال الطلب: $e')),
        );
      }
    } finally {
      setState(() => _isRequesting = false);
    }
  }

  void _showRequestDialog(UserModel doctor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('طلب طبيب - د. ${doctor.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'اكتب رسالة للطبيب لتوضيح حالتك:',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _requestMessageController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'اكتب رسالتك هنا...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _requestDoctor(doctor.uid);
            },
            child: const Text('إرسال الطلب'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF2F2), // from-red-50 equivalent
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.white,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // Header content
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Row(
                            children: [
                              const Icon(
                                Icons.arrow_right,
                                color: Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'العودة للرئيسية',
                                style: TextStyle(
                                  fontFamily: 'Janna',
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'حجز موعد طبي',
                          style: TextStyle(
                            fontFamily: 'Janna',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    children: [
                      // Appointment card
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Header section
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey[100]!,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'حجز موعد جديد',
                                    style: TextStyle(
                                      fontFamily: 'Janna',
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[900],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'اختر الطبيب المناسب وحجز موعدك',
                                    style: TextStyle(
                                      fontFamily: 'Janna',
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Content section
                            Container(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  // Doctors selection
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'اختر طبيبًا',
                                        style: TextStyle(
                                          fontFamily: 'Janna',
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[900],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      // Doctors grid
                                      if (_isLoading)
                                        const Center(child: CircularProgressIndicator())
                                      else if (_doctors.isEmpty)
                                        const Center(
                                          child: Text(
                                            'لا توجد أطباء متاحين حالياً',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        )
                                      else
                                        LayoutBuilder(
                                          builder: (context, constraints) {
                                            final isTablet = constraints.maxWidth > 600;
                                            return GridView(
                                              shrinkWrap: true,
                                              physics: const NeverScrollableScrollPhysics(),
                                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: isTablet ? 2 : 1,
                                                crossAxisSpacing: 16,
                                                mainAxisSpacing: 16,
                                                childAspectRatio: isTablet ? 2.8 : 2.1,
                                              ),
                                              children: _doctors
                                                  .map((doctor) => _buildDoctorCard(doctor))
                                                  .toList(),
                                            );
                                          },
                                        ),
                                    ],
                                  ),

                                  // Appointment details (shown only when doctor is selected)
                                  if (_selectedDoctorId != null) ...[
                                    const SizedBox(height: 24),
                                    _buildAppointmentDetails(),
                                  ],

                                  const SizedBox(height: 24),

                                  // Book appointment button
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _selectedDoctorId != null &&
                                          _dateController.text.isNotEmpty &&
                                          _timeController.text.isNotEmpty &&
                                          _reasonController.text.isNotEmpty
                                          ? () {
                                        _bookAppointment();
                                      }
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red[600],
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        textStyle: TextStyle(
                                          fontFamily: 'Janna',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: Text('إرسال طلب الحجز'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorCard(UserModel doctor) {
    final isSelected = _selectedDoctorId == doctor.uid;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? Colors.red[500]! : Colors.grey[200]!,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: isSelected ? Colors.red[50] : Colors.transparent,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedDoctorId = doctor.uid;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Doctor icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    color: Colors.blue[600],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // Doctor info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.name,
                        style: TextStyle(
                          fontFamily: 'Janna',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[900],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doctor.specialization ?? 'غير محدد',
                        style: TextStyle(
                          fontFamily: 'Janna',
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Rating
                      if (doctor.rating != null)
                        Row(
                          children: [
                            Icon(Icons.star, size: 14, color: Colors.amber[600]),
                            const SizedBox(width: 4),
                            Text(
                              '${doctor.rating!.toStringAsFixed(1)}',
                              style: TextStyle(
                                fontFamily: 'Janna',
                                color: Colors.grey[500],
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Action buttons
                Column(
                  children: [
                    // Selection indicator
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.red[500]! : Colors.grey[300]!,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Container(
                        margin: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red[500],
                        ),
                      )
                          : null,
                    ),
                    const SizedBox(height: 8),
                    // Request Doctor button
                    SizedBox(
                      width: 80,
                      height: 32,
                      child: ElevatedButton(
                        onPressed: _isRequesting ? null : () => _showRequestDialog(doctor),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          textStyle: const TextStyle(fontSize: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: _isRequesting
                            ? const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('طلب طبيب'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentDetails() {
    return Column(
      children: [
        // Date and Time inputs
        LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth > 600;
            return GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isTablet ? 2 : 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isTablet ? 3 : 2.5,
              ),
              children: [
                // Date input
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'التاريخ',
                      style: TextStyle(
                        fontFamily: 'Janna',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _dateController,
                      decoration: InputDecoration(
                        hintText: 'اختر التاريخ',
                        hintStyle: TextStyle(
                          fontFamily: 'Janna',
                          color: Colors.grey[500],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey[300]!,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.red[500]!,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      readOnly: true,
                      onTap: () {
                        _selectDate(context);
                      },
                    ),
                  ],
                ),
                // Time input
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الوقت',
                      style: TextStyle(
                        fontFamily: 'Janna',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _timeController,
                      decoration: InputDecoration(
                        hintText: 'اختر الوقت',
                        hintStyle: TextStyle(
                          fontFamily: 'Janna',
                          color: Colors.grey[500],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey[300]!,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.red[500]!,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      readOnly: true,
                      onTap: () {
                        _selectTime(context);
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        // Reason for visit
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'سبب الزيارة',
              style: TextStyle(
                fontFamily: 'Janna',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'اشرح أعراضك أو سبب الزيارة...',
                hintStyle: TextStyle(
                  fontFamily: 'Janna',
                  color: Colors.grey[500],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey[300]!,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.red[500]!,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _timeController.text = picked.format(context);
      });
    }
  }

  void _bookAppointment() {
    if (_selectedDoctorId != null) {
      final selectedDoctor = _doctors.firstWhere(
            (doctor) => doctor.uid == _selectedDoctorId,
      );

      // Show booking confirmation dialog
      _showBookingConfirmation(selectedDoctor);
    }
  }

  void _showBookingConfirmation(UserModel doctor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'تأكيد الحجز',
          style: TextStyle(
            fontFamily: 'Janna',
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.medical_services,
              color: Colors.blue,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'د. ${doctor.name}',
              style: TextStyle(
                fontFamily: 'Janna',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              doctor.specialization ?? 'غير محدد',
              style: TextStyle(
                fontFamily: 'Janna',
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'التاريخ: ${_dateController.text}',
              style: TextStyle(
                fontFamily: 'Janna',
              ),
            ),
            Text(
              'الوقت: ${_timeController.text}',
              style: TextStyle(
                fontFamily: 'Janna',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'هل تريد تأكيد حجز الموعد؟',
              style: TextStyle(
                fontFamily: 'Janna',
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    'إلغاء',
                    style: TextStyle(
                      fontFamily: 'Janna',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    _showBookingSuccess(doctor);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    'تأكيد',
                    style: TextStyle(
                      fontFamily: 'Janna',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showBookingSuccess(UserModel doctor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'تم الحجز بنجاح',
          style: TextStyle(
            fontFamily: 'Janna',
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'تم حجز موعد مع د. ${doctor.name}',
              style: TextStyle(
                fontFamily: 'Janna',
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'التاريخ: ${_dateController.text}',
              style: TextStyle(
                fontFamily: 'Janna',
                color: Colors.grey[600],
              ),
            ),
            Text(
              'الوقت: ${_timeController.text}',
              style: TextStyle(
                fontFamily: 'Janna',
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'سيتم التواصل معك لتأكيد التفاصيل',
              style: TextStyle(
                fontFamily: 'Janna',
                color: Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Return to previous page
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
              ),
              child: Text(
                'تم',
                style: TextStyle(
                  fontFamily: 'Janna',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
