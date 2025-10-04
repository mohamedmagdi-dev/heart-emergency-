-- تنظيف البيانات الموجودة وإعادة إعدادها
USE emergency_heart_db;

-- حذف البيانات الموجودة (بحذر)
DELETE FROM wallet_transactions;
DELETE FROM wallets;
DELETE FROM reviews;
DELETE FROM appointments;
DELETE FROM emergency_requests;
DELETE FROM patients;
DELETE FROM doctors;
DELETE FROM users;

-- إعادة تعيين AUTO_INCREMENT
ALTER TABLE users AUTO_INCREMENT = 1;
ALTER TABLE doctors AUTO_INCREMENT = 1;
ALTER TABLE patients AUTO_INCREMENT = 1;
ALTER TABLE wallets AUTO_INCREMENT = 1;
ALTER TABLE emergency_requests AUTO_INCREMENT = 1;
ALTER TABLE appointments AUTO_INCREMENT = 1;
ALTER TABLE reviews AUTO_INCREMENT = 1;
ALTER TABLE wallet_transactions AUTO_INCREMENT = 1;

-- إدراج المستخدمين الجدد
INSERT INTO users (email, password, user_type, phone) VALUES
('admin@admin.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin', '+967771234567'),
('doctor@doctor.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'doctor', '+967771234568'),
('patient@patient.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'patient', '+967771234569');

-- إدراج الطبيب
INSERT INTO doctors (user_id, name, specialization, experience_years, license_number, latitude, longitude, is_available, rating) VALUES
(2, 'د. أحمد محمد', 'طب عام', 5, 'DOC123456', 15.3694, 44.1910, TRUE, 4.5);

-- إدراج المريض
INSERT INTO patients (user_id, name, age, gender, address, emergency_contact) VALUES
(3, 'مريض تجريبي', 30, 'ذكر', 'صنعاء، اليمن', '+967771234570');

-- إدراج المحافظ
INSERT INTO wallets (user_id, balance) VALUES
(1, 0.00),
(2, 0.00),
(3, 150.00);

-- إضافة بعض المعاملات التجريبية
INSERT INTO wallet_transactions (wallet_id, amount, type, description) VALUES
(3, 150.00, 'credit', 'رصيد ابتدائي'),
(3, -50.00, 'debit', 'دفع مقابل خدمة طبية');

-- إضافة بعض طلبات الطوارئ التجريبية
INSERT INTO emergency_requests (patient_id, patient_latitude, patient_longitude, patient_address, symptoms, urgency_level, status) VALUES
(1, 15.3694, 44.1910, 'صنعاء، اليمن', 'ألم في الصدر وصعوبة في التنفس', 'high', 'pending');

-- إضافة بعض المواعيد التجريبية
INSERT INTO appointments (patient_id, doctor_id, appointment_date, appointment_time, reason, status) VALUES
(1, 1, '2024-02-01', '10:00:00', 'فحص دوري', 'pending');

SELECT 'تم إعداد البيانات بنجاح!' as message;
