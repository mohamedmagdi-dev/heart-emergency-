-- بيانات تجريبية مبسطة للاختبار
USE emergency_heart_db;

-- إدراج مستخدمين تجريبيين
INSERT IGNORE INTO users (id, email, password, user_type, phone) VALUES
(1, 'admin@admin.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin', '+967771234567'),
(2, 'doctor@doctor.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'doctor', '+967771234568'),
(3, 'patient@patient.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'patient', '+967771234569');

-- إدراج طبيب تجريبي
INSERT IGNORE INTO doctors (id, user_id, name, specialization, experience_years, license_number, latitude, longitude, is_available, rating) VALUES
(1, 2, 'د. أحمد محمد', 'طب عام', 5, 'DOC123456', 15.3694, 44.1910, TRUE, 4.5);

-- إدراج مريض تجريبي
INSERT IGNORE INTO patients (id, user_id, name, age, gender, address, emergency_contact) VALUES
(1, 3, 'مريض تجريبي', 30, 'ذكر', 'صنعاء، اليمن', '+967771234570');

-- إدراج محافظ للمستخدمين
INSERT IGNORE INTO wallets (id, user_id, balance) VALUES
(1, 1, 0.00),
(2, 2, 0.00),
(3, 3, 150.00);
