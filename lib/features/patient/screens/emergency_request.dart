import 'package:flutter/material.dart';

class EmergencyRequestPage extends StatelessWidget {
  const EmergencyRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF2F2), // from-red-50 equivalent
      body: SafeArea(
        child: Column(
          children: [
            // Emergency header
            Container(
              color: Colors.red[600],
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.arrow_right,
                            color: Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'العودة',
                            style: TextStyle(
                              fontFamily: 'Janna',
                              color: Colors.red[100],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.warning,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'طلب طوارئ',
                          style: TextStyle(
                            fontFamily: 'Janna',
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.green[400],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'متاح 24/7',
                          style: TextStyle(
                            fontFamily: 'Janna',
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
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
                      // Location section
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 32),
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
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              // Section header
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'تحديد الموقع',
                                    style: TextStyle(
                                      fontFamily: 'Janna',
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[900],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_pin,
                                        color: Colors.green[600],
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'تم التحديد',
                                        style: TextStyle(
                                          fontFamily: 'Janna',
                                          color: Colors.green[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Location info
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.navigation,
                                          color: Colors.blue[600],
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'موقعك الحالي',
                                              style: TextStyle(
                                                fontFamily: 'Janna',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey[900],
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'صنعاء، اليمن - موقع افتراضي (يرجى السماح بالوصول للموقع)',
                                              style: TextStyle(
                                                fontFamily: 'Janna',
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'الإحداثيات: 15.369400, 44.191000',
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
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blue[600],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            // Handle location reset
                                          },
                                          borderRadius: BorderRadius.circular(8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                            child: Text(
                                              'إعادة تحديد',
                                              style: TextStyle(
                                                fontFamily: 'Janna',
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Location permission warning
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.yellow[50],
                                  border: Border.all(color: Colors.yellow[200]!),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.warning,
                                      color: Colors.yellow[600],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'تم رفض إذن تحديد الموقع. يرجى السماح بالوصول للموقع.',
                                        style: TextStyle(
                                          fontFamily: 'Janna',
                                          color: Colors.yellow[800],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Location info footer
                              Column(
                                children: [
                                  Text(
                                    'سيتم إرسال أقرب طبيب متاح إلى موقعك فور تأكيد الطلب',
                                    style: TextStyle(
                                      fontFamily: 'Janna',
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _buildLocationFeature('📍 دقة عالية'),
                                      const SizedBox(width: 16),
                                      _buildLocationFeature('⚡ تحديث فوري'),
                                      const SizedBox(width: 16),
                                      _buildLocationFeature('🔒 خصوصية محفوظة'),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Available doctors section
                      Column(
                        children: [
                          // Section header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'الأطباء المتاحون',
                                style: TextStyle(
                                  fontFamily: 'Janna',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[900],
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '2 طبيب متاح',
                                    style: TextStyle(
                                      fontFamily: 'Janna',
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue[600],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          // Handle refresh
                                        },
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.refresh,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'تحديث',
                                                style: TextStyle(
                                                  fontFamily: 'Janna',
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Doctors list
                          Column(
                            children: [
                              _buildDoctorCard(
                                name: 'د. mohamed',
                                specialty: 'internal',
                                experience: '3-5',
                                rating: 4.5,
                                reviewCount: 76,
                                distance: '6.2 كم',
                                time: '21 دقيقة',
                                price: '51 ر.س',
                                email: 'mo@mo.mo',
                                phone: '01155889963',
                                lastActive: 'منذ 2 دقيقة',
                              ),
                              const SizedBox(height: 16),
                              _buildDoctorCard(
                                name: 'د. mohamed',
                                specialty: 'internal',
                                experience: '3-5',
                                rating: 4.5,
                                reviewCount: 80,
                                distance: '7.2 كم',
                                time: '12 دقيقة',
                                price: '33 ر.س',
                                email: 'mo@mo.mo',
                                phone: '01155889963',
                                lastActive: 'منذ 4 دقيقة',
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Important warning
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 32),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          border: Border.all(color: Colors.red[200]!),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.warning,
                              color: Colors.red[600],
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'تنبيه مهم',
                                    style: TextStyle(
                                      fontFamily: 'Janna',
                                      color: Colors.red[800],
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'في حالات الطوارئ الحرجة التي تستدعي تدخل طبي فوري (مثل صعوبة التنفس، آلام الصدر الحادة، فقدان الوعي)، يُنصح بالتوجه فوراً إلى أقرب مستشفى أو الاتصال بخدمات الطوارئ.',
                                    style: TextStyle(
                                      fontFamily: 'Janna',
                                      color: Colors.red[700],
                                      fontSize: 12,
                                      height: 1.5,
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

  Widget _buildLocationFeature(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Janna',
        color: Colors.grey[500],
        fontSize: 12,
      ),
    );
  }

  Widget _buildDoctorCard({
    required String name,
    required String specialty,
    required String experience,
    required double rating,
    required int reviewCount,
    required String distance,
    required String time,
    required String price,
    required String email,
    required String phone,
    required String lastActive,
  }) {
    return Container(
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
          // Doctor info
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Doctor image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.blue[100]!,
                      width: 4,
                    ),
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://images.pexels.com/photos/5452293/pexels-photo-5452293.jpeg?auto=compress&cs=tinysrgb&w=400',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Doctor details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: TextStyle(
                                    fontFamily: 'Janna',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[900],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Specialty and experience
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[100],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        specialty,
                                        style: TextStyle(
                                          fontFamily: 'Janna',
                                          color: Colors.blue[800],
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '•',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      experience,
                                      style: TextStyle(
                                        fontFamily: 'Janna',
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '•',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green[100],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'موثق',
                                        style: TextStyle(
                                          fontFamily: 'Janna',
                                          color: Colors.green[800],
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Rating, distance, time
                                Row(
                                  children: [
                                    // Rating
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          color: Colors.yellow[700],
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          rating.toString(),
                                          style: TextStyle(
                                            fontFamily: 'Janna',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '($reviewCount)',
                                          style: TextStyle(
                                            fontFamily: 'Janna',
                                            color: Colors.grey[500],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 16),
                                    // Distance
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_pin,
                                          color: Colors.green[600],
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          distance,
                                          style: TextStyle(
                                            fontFamily: 'Janna',
                                            color: Colors.green[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 16),
                                    // Time
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          color: Colors.blue[600],
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          time,
                                          style: TextStyle(
                                            fontFamily: 'Janna',
                                            color: Colors.blue[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Contact info
                                Row(
                                  children: [
                                    Text(
                                      '📧 $email',
                                      style: TextStyle(
                                        fontFamily: 'Janna',
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      '📞 $phone',
                                      style: TextStyle(
                                        fontFamily: 'Janna',
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Price
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                price,
                                style: TextStyle(
                                  fontFamily: 'Janna',
                                  color: Colors.green[600],
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '+ 12% عمولة',
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
                      const SizedBox(height: 16),
                      // Call button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle emergency call
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            textStyle: TextStyle(
                              fontFamily: 'Janna',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.favorite, size: 20),
                              const SizedBox(width: 8),
                              Text('استدعاء فوري'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Availability footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              border: Border(
                top: BorderSide(
                  color: Colors.grey[200]!,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.green[500],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'متاح الآن',
                      style: TextStyle(
                        fontFamily: 'Janna',
                        color: Colors.green[700],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Text(
                  'آخر نشاط: $lastActive',
                  style: TextStyle(
                    fontFamily: 'Janna',
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}