import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedTab = 0; // 0: Overview, 1: Doctors, 2: Patients, 3: Transactions

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF6FF),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple[700]!, Colors.indigo[800]!],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    // Header content
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                // Handle logout
                                //Navigator.pop(context);
                                context.go('/login');
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.logout,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'الخروج',
                                      style: TextStyle(
                                        fontFamily: 'Janna',
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'admin@emergency-heart.com',
                                      maxLines: 1,
                                      softWrap: false,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontFamily: 'Janna',
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'مدير النظام',
                                      maxLines: 1,
                                      softWrap: false,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontFamily: 'Janna',
                                        color: Colors.purple[100],
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'لوحة تحكم المدير',
                              style: TextStyle(
                                fontFamily: 'Janna',
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'اداره المنصه',
                              style: TextStyle(
                                fontFamily: 'Janna',
                                color: Colors.purple[100],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    children: [
                      // Action buttons
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 32),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.end,
                          children: [
                            _buildActionButton(
                              'إضافة طبيب جديد',
                              Icons.person_add,
                              Colors.blue[500]!,
                              Colors.blue[700]!,
                            ),
                            _buildActionButton(
                              'إضافة مريض جديد',
                              Icons.person_outline,
                              Colors.green[500]!,
                              Colors.green[700]!,
                            ),
                            _buildActionButton(
                              'إضافة معاملة مالية',
                              Icons.credit_card,
                              Colors.purple[500]!,
                              Colors.indigo[700]!,
                            ),
                          ],
                        ),
                      ),

                      // Navigation tabs
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
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildNavTab('نظرة عامة', Icons.settings, 0),
                                const SizedBox(width: 32),
                                _buildNavTab('الأطباء', Icons.person, 1),
                                const SizedBox(width: 32),
                                _buildNavTab('المرضى', Icons.people, 2),
                                const SizedBox(width: 32),
                                _buildNavTab('المعاملات', Icons.credit_card, 3),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Content based on selected tab
                      _buildTabContent(),
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

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0: // Overview
        return _buildOverviewContent();
      case 1: // Doctors
        return _buildDoctorsContent();
      case 2: // Patients
        return _buildPatientsContent();
      case 3: // Transactions
        return _buildTransactionsContent();
      default:
        return _buildOverviewContent();
    }
  }

  Widget _buildOverviewContent() {
    return Column(
      children: [
        // User statistics
        _buildStatisticsSection(
          'إحصائيات المستخدمين المسجلين',
          'مخزنة محلياً',
          Colors.blue[100]!,
          Colors.blue[800]!,
          [
            _buildStatCard(
              '1',
              'الأطباء المسجلون',
              Icons.person_add,
              Colors.blue[600]!,
              Colors.cyan[500]!,
            ),
            _buildStatCard(
              '0',
              'المرضى المسجلون',
              Icons.verified,
              Colors.green[600]!,
              Colors.green[500]!,
            ),
            _buildStatCard(
              '0 ر.س',
              'إيرادات حقيقية',
              Icons.trending_up,
              Colors.purple[600]!,
              Colors.pink[500]!,
            ),
          ],
        ),
        const SizedBox(height: 32),

        // System statistics
        _buildStatisticsSection(
          'إحصائيات العمولات والتحقق',
          'بيانات النظام',
          Colors.amber[100]!,
          Colors.amber[800]!,
          [
            _buildStatCard(
              '0 ر.س',
              'العمولات المحصلة',
              Icons.account_balance_wallet,
              Colors.amber[500]!,
              Colors.orange[600]!,
            ),
            _buildStatCard(
              '1',
              'طلبات التحقق',
              Icons.analytics,
              Colors.yellow[500]!,
              Colors.amber[600]!,
            ),
            _buildStatCard(
              '1',
              'المستخدمون المحظورون',
              Icons.block,
              Colors.red[500]!,
              Colors.pink[600]!,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDoctorsContent() {
    return Container(
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
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'مخزنة محلياً',
                          style: TextStyle(
                            fontFamily: 'Janna',
                            color: Colors.blue[800],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'الأطباء المسجلون',
                        style: TextStyle(
                          fontFamily: 'Janna',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[900],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 150,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'البحث في الأطباء...',
                        hintStyle: TextStyle(
                          fontFamily: 'Janna',
                          color: Colors.grey[500],
                        ),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.blue[500]!,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Doctors Table
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('الطبيب')),
                  DataColumn(label: Text('التخصص')),
                  DataColumn(label: Text('الحالة')),
                  DataColumn(label: Text('الإجراءات')),
                ],
                rows: [
                  _buildDoctorRow('د. محمد أحمد', 'موثق'),
                  _buildDoctorRow('د. فاطمة الزهراني', 'قيد المراجعة'),
                  _buildDoctorRow('د. أحمد الشريف', 'موثق'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildDoctorRow(String name, String status) {
    Color statusColor = status == 'موثق' ? Colors.green : Colors.yellow;
    Color statusBgColor = status == 'موثق' ? Colors.green[100]! : Colors.yellow[100]!;

    return DataRow(cells: [
      DataCell(Text(
        name,
        style: TextStyle(
          fontFamily: 'Janna',
          fontWeight: FontWeight.w500,
        ),
      )),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusBgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          status,
          style: TextStyle(
            fontFamily: 'Janna',
            color: Colors.green[800],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      )),
      DataCell(Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.visibility, color: Colors.blue[600], size: 20),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.edit, color: Colors.green[600], size: 20),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.delete, color: Colors.red[600], size: 20),
          ),
        ],
      )),
      const DataCell(SizedBox.shrink()),
    ]);
  }

  Widget _buildPatientsContent() {
    return Container(
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
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'قائمة المرضى',
                  style: TextStyle(
                    fontFamily: 'Janna',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
                Container(
                  width: 200,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'البحث في المرضى...',
                      hintStyle: TextStyle(
                        fontFamily: 'Janna',
                        color: Colors.grey[500],
                      ),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.blue[500]!,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Patients Table
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('المريض')),
                  DataColumn(label: Text('الحالة')),
                  DataColumn(label: Text('الإجراءات')),
                ],
                rows: [
                  _buildPatientRow('أحمد علي', 'نشط', Colors.green),
                  _buildPatientRow('سارة سالم', 'نشط', Colors.green),
                  _buildPatientRow('خالد محمود', 'محظور', Colors.red),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildPatientRow(String name, String status, Color statusColor) {
    Color statusBgColor = statusColor == Colors.green ? Colors.green[100]! : Colors.red[100]!;

    return DataRow(cells: [
      DataCell(Text(
        name,
        style: TextStyle(
          fontFamily: 'Janna',
          fontWeight: FontWeight.w500,
        ),
      )),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusBgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          status,
          style: TextStyle(
            fontFamily: 'Janna',
            color: Colors.green[800],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      )),
      DataCell(Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.visibility, color: Colors.blue[600], size: 20),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.edit, color: Colors.green[600], size: 20),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.delete, color: Colors.red[600], size: 20),
          ),
        ],
      )),
    ]);
  }

  Widget _buildTransactionsContent() {
    return Container(
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
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'قائمة المعاملات المالية',
                    style: TextStyle(
                      fontFamily: 'Janna',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
                  ),
                  Container(
                    width: 200,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'البحث في المعاملات...',
                        hintStyle: TextStyle(
                          fontFamily: 'Janna',
                          color: Colors.grey[500],
                        ),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.blue[500]!,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Transactions Table
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('المبلغ')),
                  DataColumn(label: Text('العمولة')),
                  DataColumn(label: Text('الإجراءات')),
                ],
                rows: [
                  _buildTransactionRow('200 ر.س', '24 ر.س'),
                  _buildTransactionRow('350 ر.س', '42 ر.س'),
                  _buildTransactionRow('120 ر.س', '14 ر.س'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildTransactionRow(String amount, String commission) {
    return DataRow(cells: [
      DataCell(Text(
        amount,
        style: TextStyle(
          fontFamily: 'Janna',
          fontWeight: FontWeight.w500,
        ),
      )),
      DataCell(Text(
        commission,
        style: TextStyle(
          fontFamily: 'Janna',
          fontWeight: FontWeight.w500,
        ),
      )),
      DataCell(Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.visibility, color: Colors.blue[600], size: 20),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.edit, color: Colors.green[600], size: 20),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.delete, color: Colors.red[600], size: 20),
          ),
        ],
      )),
    ]);
  }

  Widget _buildActionButton(
      String text,
      IconData icon,
      Color startColor,
      Color endColor,
      ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [startColor, endColor]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: startColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Handle button action
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: TextStyle(
                    fontFamily: 'Janna',
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavTab(String text, IconData icon, int tabIndex) {
    bool isActive = _selectedTab == tabIndex;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isActive ? Colors.purple[500]! : Colors.transparent,
            width: 2,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedTab = tabIndex;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isActive ? Colors.purple[600]! : Colors.grey[500],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: TextStyle(
                    fontFamily: 'Janna',
                    color: isActive ? Colors.purple[600]! : Colors.grey[500],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(
      String title,
      String badgeText,
      Color badgeColor,
      Color badgeTextColor,
      List<Widget> statCards,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  fontFamily: 'Janna',
                  color: badgeTextColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Janna',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 768
                ? 3
                : constraints.maxWidth > 480
                ? 2
                : 1;
            return GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.3,
              ),
              children: statCards,
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String value,
      String label,
      IconData icon,
      Color startColor,
      Color endColor,
      ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [startColor, endColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: startColor.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Handle card tap
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Stack(
                children: [
                  Positioned(
                    right: 16,
                    top: 16,
                    child: Opacity(
                      opacity: 0.3,
                      child: Icon(icon, color: Colors.white, size: 32),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            value,
                            style: TextStyle(
                              fontFamily: 'Janna',
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            label,
                            style: TextStyle(
                              fontFamily: 'Janna',
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}