// 🟢 Added: Admin screen for viewing completed requests per doctor and per patient
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/request_model.dart';
import '../../../data/models/user_model.dart';
import '../../../services/request_service.dart';
import '../../../services/firestore_service.dart';

class AdminCompletedRequestsScreen extends ConsumerStatefulWidget {
  const AdminCompletedRequestsScreen({super.key});

  @override
  ConsumerState<AdminCompletedRequestsScreen> createState() => _AdminCompletedRequestsScreenState();
}

class _AdminCompletedRequestsScreenState extends ConsumerState<AdminCompletedRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final RequestService _requestService = RequestService();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الطلبات المكتملة'),
        backgroundColor: Colors.red[600],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'جميع الطلبات', icon: Icon(Icons.list)),
            Tab(text: 'حسب الطبيب', icon: Icon(Icons.local_hospital)),
            Tab(text: 'حسب المريض', icon: Icon(Icons.person)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllCompletedRequestsTab(),
          _buildByDoctorTab(),
          _buildByPatientTab(),
        ],
      ),
    );
  }

  Widget _buildAllCompletedRequestsTab() {
    return StreamBuilder<List<RequestModel>>(
      stream: _requestService.getAllEmergencyRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('خطأ في تحميل البيانات: ${snapshot.error}'),
          );
        }

        final requests = snapshot.data ?? [];
        final completedRequests = requests.where((r) => r.status == RequestStatus.completed).toList();

        if (completedRequests.isEmpty) {
          return const Center(
            child: Text('لا توجد طلبات مكتملة'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: completedRequests.length,
          itemBuilder: (context, index) {
            final request = completedRequests[index];
            return _buildRequestCard(request);
          },
        );
      },
    );
  }

  Widget _buildByDoctorTab() {
    return StreamBuilder<List<UserModel>>(
      stream: _firestoreService.getUsersByRole('doctor'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('خطأ في تحميل الأطباء: ${snapshot.error}'),
          );
        }

        final doctors = snapshot.data ?? [];

        if (doctors.isEmpty) {
          return const Center(
            child: Text('لا توجد أطباء'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: doctors.length,
          itemBuilder: (context, index) {
            final doctor = doctors[index];
            return _buildDoctorCard(doctor);
          },
        );
      },
    );
  }

  Widget _buildByPatientTab() {
    return StreamBuilder<List<UserModel>>(
      stream: _firestoreService.getUsersByRole('patient'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('خطأ في تحميل المرضى: ${snapshot.error}'),
          );
        }

        final patients = snapshot.data ?? [];

        if (patients.isEmpty) {
          return const Center(
            child: Text('لا توجد مرضى'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: patients.length,
          itemBuilder: (context, index) {
            final patient = patients[index];
            return _buildPatientCard(patient);
          },
        );
      },
    );
  }

  Widget _buildDoctorCard(UserModel doctor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(
            doctor.name.isNotEmpty ? doctor.name[0].toUpperCase() : 'د',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(doctor.name),
        subtitle: Text(doctor.specialization ?? 'غير محدد'),
        children: [
          StreamBuilder<List<RequestModel>>(
            stream: _requestService.getCompletedRequestsForDoctor(doctor.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final requests = snapshot.data ?? [];

              if (requests.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('لا توجد طلبات مكتملة'),
                );
              }

              return Column(
                children: requests.map((request) => _buildRequestCard(request)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(UserModel patient) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green[100],
          child: Text(
            patient.name.isNotEmpty ? patient.name[0].toUpperCase() : 'م',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(patient.name),
        subtitle: Text(patient.phone),
        children: [
          StreamBuilder<List<RequestModel>>(
            stream: _requestService.getCompletedRequestsForPatient(patient.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final requests = snapshot.data ?? [];

              if (requests.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('لا توجد طلبات مكتملة'),
                );
              }

              return Column(
                children: requests.map((request) => _buildRequestCard(request)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(RequestModel request) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'طلب مكتمل',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[600],
                    ),
                  ),
                ),
                Text(
                  _formatDateTime(request.completedAt ?? request.createdAt),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildDetailRow('الأعراض', request.symptoms),
            _buildDetailRow('مستوى الأولوية', request.urgencyLevel),
            if (request.price != null)
              _buildDetailRow('السعر', '${request.price!.toStringAsFixed(2)} SAR'),
            if (request.finalPrice != null)
              _buildDetailRow('السعر النهائي', '${request.finalPrice!.toStringAsFixed(2)} SAR'),
            if (request.commissionAmount != null)
              _buildDetailRow('العمولة', '${request.commissionAmount!.toStringAsFixed(2)} SAR'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FutureBuilder<UserModel?>(
                    future: _firestoreService.getUser(request.patientId),
                    builder: (context, snapshot) {
                      final patient = snapshot.data;
                      return Text(
                        'المريض: ${patient?.name ?? 'غير معروف'}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      );
                    },
                  ),
                ),
                if (request.doctorId != null)
                  Expanded(
                    child: FutureBuilder<UserModel?>(
                      future: _firestoreService.getUser(request.doctorId!),
                      builder: (context, snapshot) {
                        final doctor = snapshot.data;
                        return Text(
                          'الطبيب: ${doctor?.name ?? 'غير معروف'}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
