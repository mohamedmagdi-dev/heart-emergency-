
import 'package:flutter/material.dart';

import '../widgets/customwithdrawdialog.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  _DoctorDashboardScreenState createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  bool _isAvailable = true;
  final List<AppointmentRequest> _requests = [
    AppointmentRequest(
      patientName: 'مريض طوارئ',
      age: 45,
      gender: 'ذكر',
      priority: 'عالية',
      location: 'غير محدد • غير محدد',
      timeAgo: 'الآن',
      symptoms: 'حالة طارئة تتطلب استجابة سريعة.',
      price: 60,
      commission: 12,
    ),
    AppointmentRequest(
      patientName: 'أحمد محمد',
      age: 34,
      gender: 'ذكر',
      priority: 'عالية',
      location: 'شارع جمال، صنعاء • 2.5 كم',
      timeAgo: '5 دقائق',
      symptoms: 'صداع حاد وغثيان مستمر.',
      price: 150,
      commission: 12,
    ),
    AppointmentRequest(
      patientName: 'فاطمة علي',
      age: 28,
      gender: 'أنثى',
      priority: 'متوسطة',
      location: 'حي حدة، صنعاء • 4.1 كم',
      timeAgo: '12 دقيقة',
      symptoms: 'ارتفاع في درجة الحرارة وألم في المفاصل.',
      price: 120,
      commission: 12,
    ),
  ];

  void _addTestRequest() {
    setState(() {
      _requests.insert(0, AppointmentRequest(
        patientName: 'مريض تجريبي',
        age: 30,
        gender: 'ذكر',
        priority: 'منخفضة',
        location: 'موقع تجريبي',
        timeAgo: 'الآن',
        symptoms: 'أعراض تجريبية',
        price: 100,
        commission: 12,
      ));
    });
  }

  void _resetStatistics() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم إعادة تعيين الإحصائيات')),
    );
  }

  void _clearNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم مسح الإشعارات')),
    );
  }

  void _addTestNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم إضافة إشعار تجريبي')),
    );
  }

  void _acceptRequest(int index) {
    setState(() {
      _requests.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم قبول الطلب')),
    );
  }

  void _rejectRequest(int index) {
    setState(() {
      _requests.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم رفض الطلب')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(isLargeScreen),
            Padding(
              padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
              child: Column(
                children: [
                  _buildStatisticsCards(isLargeScreen),
                  SizedBox(height: 16),
                  _buildWalletBalance(isLargeScreen),
                  SizedBox(height: 16),
                  _buildControlTools(isLargeScreen),
                  SizedBox(height: 16),
                  _buildAppointmentBookings(),
                  SizedBox(height: 16),
                  _buildNewRequests(isLargeScreen),
                  SizedBox(height: 16),
                  _buildDoctorProfile(isLargeScreen),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isLargeScreen) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isLargeScreen ? 20 : 16,
            vertical: 12,
          ),
          child: Row(
            children: [
              // Doctor Info - Made more compact for small screens
              Expanded(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: isLargeScreen ? 24 : 20,
                      backgroundImage: NetworkImage(
                        'https://images.pexels.com/photos/5452293/pexels-photo-5452293.jpeg?auto=compress&cs=tinysrgb&w=150',
                      ),
                    ),
                    SizedBox(width: isLargeScreen ? 16 : 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'د. ahmed ali',
                            style: TextStyle(
                              fontSize: isLargeScreen ? 20 : 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'general • 1-2 سنوات خبرة',
                            style: TextStyle(
                              fontSize: isLargeScreen ? 14 : 12,
                              color: Color(0xFF6B7280),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Availability Toggle - Hide text on very small screens
              if (isLargeScreen) ...[
                Row(
                  children: [
                    Switch(
                      value: _isAvailable,
                      onChanged: (value) {
                        setState(() {
                          _isAvailable = value;
                        });
                      },
                      activeColor: Color(0xFF16A34A),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'متاح',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Switch(
                  value: _isAvailable,
                  onChanged: (value) {
                    setState(() {
                      _isAvailable = value;
                    });
                  },
                  activeColor: Color(0xFF16A34A),
                ),
              ],

              // Icons - Adjust spacing based on screen size
              SizedBox(width: isLargeScreen ? 16 : 8),
              _buildNotificationIcon(),
              SizedBox(width: isLargeScreen ? 12 : 8),
              IconButton(
                icon: Icon(Icons.settings, color: Color(0xFF6B7280)),
                onPressed: () {},
              ),
              SizedBox(width: isLargeScreen ? 12 : 8),
              IconButton(
                icon: Icon(Icons.logout, color: Color(0xFF6B7280)),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return IconButton(
      icon: Stack(
        children: [
          Icon(Icons.notifications, color: Color(0xFF6B7280)),
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Color(0xFFEF4444),
                shape: BoxShape.circle,
              ),
              constraints: BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                '8',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
      onPressed: () {
        _showNotificationsDialog();
      },
    );
  }

  Widget _buildStatisticsCards(bool isLargeScreen) {
    return GridView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isLargeScreen ? 4 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: isLargeScreen ? 1.2 : 1.4,
      ),
      children: [
        _buildStatCard(
          'إجمالي الأرباح',
          '65 ر.س',
          Icons.account_balance_wallet,
          Color(0xFF16A34A),
        ),
        _buildStatCard(
          'أرباح اليوم',
          '65 ر.س',
          Icons.access_time,
          Color(0xFF2563EB),
        ),
        _buildStatCard(
          'الزيارات المكتملة',
          '1',
          Icons.people,
          Color(0xFF9333EA),
        ),
        _buildStatCard(
          'التقييم',
          '0',
          Icons.star,
          Color(0xFFCA8A04),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletBalance(bool isLargeScreen) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF16A34A), Color(0xFF15803D)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isLargeScreen ? 24 : 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'رصيد المحفظة',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 20 : 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '65 ر.س',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 32 : 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'متاح للسحب',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFBBF7D0),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return WithdrawDialog();
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Color(0xFF16A34A),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isLargeScreen ? 20 : 16,
                  vertical: 12,
                ),
              ),
              child: Text(
                'سحب الأموال',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlTools(bool isLargeScreen) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isLargeScreen ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'أدوات التحكم',
              style: TextStyle(
                fontSize: isLargeScreen ? 20 : 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildControlButton(
                        'إضافة طلب تجريبي',
                        Color(0xFF2563EB),
                        _addTestRequest,
                        isLargeScreen,
                      ),
                      _buildControlButton(
                        'إعادة تعيين الإحصائيات',
                        Color(0xFFCA8A04),
                        _resetStatistics,
                        isLargeScreen,
                      ),
                      _buildControlButton(
                        'مسح الإشعارات',
                        Color(0xFFDC2626),
                        _clearNotifications,
                        isLargeScreen,
                      ),
                      _buildControlButton(
                        'إشعار تجريبي',
                        Color(0xFF2563EB),
                        _addTestNotification,
                        isLargeScreen,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(String text, Color color, VoidCallback onPressed, bool isLargeScreen) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isLargeScreen ? 20 : 16,
          vertical: isLargeScreen ? 16 : 12,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isLargeScreen ? 14 : 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAppointmentBookings() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'حجوزات المواعيد',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '0 حجز',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E40AF),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 48, color: Color(0xFFD1D5DB)),
                  SizedBox(height: 16),
                  Text(
                    'لا توجد حجوزات مواعيد',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'ستظهر حجوزات المواعيد هنا عند توفرها',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewRequests(bool isLargeScreen) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الطلبات الجديدة',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${_requests.length} طلب جديد',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF991B1B),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ..._requests.asMap().entries.map((entry) {
            final index = entry.key;
            final request = entry.value;
            return _buildRequestItem(request, index, isLargeScreen);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildRequestItem(AppointmentRequest request, int index, bool isLargeScreen) {
    Color priorityColor;
    switch (request.priority) {
      case 'عالية':
        priorityColor = Color(0xFFFEE2E2);
        break;
      case 'متوسطة':
        priorityColor = Color(0xFFFEF3C7);
        break;
      default:
        priorityColor = Color(0xFFD1FAE5);
    }

    Color priorityTextColor;
    switch (request.priority) {
      case 'عالية':
        priorityTextColor = Color(0xFF991B1B);
        break;
      case 'متوسطة':
        priorityTextColor = Color(0xFF92400E);
        break;
      default:
        priorityTextColor = Color(0xFF065F46);
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Patient Info Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFFDBEAFE),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.people, size: 20, color: Color(0xFF2563EB)),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  request.patientName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF111827),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${request.age} سنة • ${request.gender}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: priorityColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              request.priority,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: priorityTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      // Location and Time - Stack on small screens
                      if (isLargeScreen)
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 16, color: Color(0xFF6B7280)),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                request.location,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 16),
                            Icon(Icons.access_time, size: 16, color: Color(0xFF6B7280)),
                            SizedBox(width: 4),
                            Text(
                              'طلب منذ ${request.timeAgo}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 14, color: Color(0xFF6B7280)),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    request.location,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6B7280),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 14, color: Color(0xFF6B7280)),
                                SizedBox(width: 4),
                                Text(
                                  'طلب منذ ${request.timeAgo}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${request.price} ر.س',
                      style: TextStyle(
                        fontSize: isLargeScreen ? 20 : 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                    Text(
                      '+ ${request.commission}% عمولة',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 12),

            // Symptoms
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: isLargeScreen ? 14 : 12,
                    color: Color(0xFF374151),
                  ),
                  children: [
                    TextSpan(
                      text: 'الأعراض: ',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    TextSpan(text: request.symptoms),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Action Buttons - Responsive layout
            _buildActionButtons(index, isLargeScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(int index, bool isLargeScreen) {
    if (isLargeScreen) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _acceptRequest(index),
              icon: Icon(Icons.check_circle, size: 20),
              label: Text('قبول الطلب'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2563EB),
                foregroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () => _rejectRequest(index),
            icon: Icon(Icons.close, size: 20),
            label: Text('رفض'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFE5E7EB),
              foregroundColor: Color(0xFF374151),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
          ),
          SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.navigation, size: 20),
            label: Text('خريطة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2563EB),
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
          ),
        ],
      );
    } else {
      // Mobile layout - vertical buttons
      return Column(
        children: [
          // Accept Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _acceptRequest(index),
              icon: Icon(Icons.check_circle, size: 20),
              label: Text('قبول الطلب'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2563EB),
                foregroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          SizedBox(height: 8),
          // Other buttons in a row
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _rejectRequest(index),
                  icon: Icon(Icons.close, size: 18),
                  label: Text('رفض'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFE5E7EB),
                    foregroundColor: Color(0xFF374151),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.navigation, size: 18),
                  label: Text('خريطة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildDoctorProfile(bool isLargeScreen) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      padding: EdgeInsets.all(isLargeScreen ? 24 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: isLargeScreen
          ? Row(
        children: [
          CircleAvatar(
            radius: 64,
            backgroundImage: NetworkImage(
              'https://images.pexels.com/photos/5452293/pexels-photo-5452293.jpeg?auto=compress&cs=tinysrgb&w=200',
            ),
            backgroundColor: Colors.white,
          ),
          SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'د. ahmed ali',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'general',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1D4ED8),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '1-2 سنوات خبرة',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                  ),
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Color(0xFFDBEAFE),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'SAR',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E40AF),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'متاح',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF166534),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'تقييم: 0',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      )
          : Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundImage: NetworkImage(
              'https://images.pexels.com/photos/5452293/pexels-photo-5452293.jpeg?auto=compress&cs=tinysrgb&w=200',
            ),
            backgroundColor: Colors.white,
          ),
          SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'د. ahmed ali',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              SizedBox(height: 4),
              Text(
                'general',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1D4ED8),
                ),
              ),
              SizedBox(height: 2),
              Text(
                '1-2 سنوات خبرة',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
              SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFFDBEAFE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'SAR',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E40AF),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'متاح',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF166534),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'تقييم: 0',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showNotificationsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('الإشعارات'),
            TextButton(
              onPressed: _addTestNotification,
              child: Text('+ إشعار تجريبي'),
            ),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildNotificationItem('تم قبول طلب من مريض تجريبي 18 - 65 ر.س', '٧‏/٤‏/١٤٤٧ هـ ١٠:٢٢:١٧ ص'),
              _buildNotificationItem('طلب جديد من مريض تجريبي 18', '9/29/2025, 10:21:37 AM'),
              _buildNotificationItem('تم رفض طلب من مريض تجريبي 51', '9/29/2025, 10:21:26 AM'),
              _buildNotificationItem('تم رفض طلب من مريض تجريبي 72', '9/29/2025, 10:21:22 AM'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(String title, String time) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }
}

class AppointmentRequest {
  final String patientName;
  final int age;
  final String gender;
  final String priority;
  final String location;
  final String timeAgo;
  final String symptoms;
  final int price;
  final int commission;

  AppointmentRequest({
    required this.patientName,
    required this.age,
    required this.gender,
    required this.priority,
    required this.location,
    required this.timeAgo,
    required this.symptoms,
    required this.price,
    required this.commission,
  });
}
