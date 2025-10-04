-- إصلاح جدول المستخدمين وإضافة الأعمدة المفقودة
USE emergency_heart_db;

-- إضافة الأعمدة المفقودة لجدول المستخدمين
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE,
ADD COLUMN IF NOT EXISTS is_blocked BOOLEAN DEFAULT FALSE;

-- تحديث المستخدمين الموجودين ليكونوا نشطين
UPDATE users SET is_active = TRUE, is_blocked = FALSE WHERE is_active IS NULL;

-- إضافة فهارس للأعمدة الجديدة
CREATE INDEX IF NOT EXISTS idx_users_active ON users(is_active);
CREATE INDEX IF NOT EXISTS idx_users_blocked ON users(is_blocked);

-- إضافة بعض البيانات التجريبية الإضافية
INSERT IGNORE INTO users (email, password, user_type, phone, is_active, is_blocked) VALUES
('test_doctor@test.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'doctor', '+967771234111', TRUE, FALSE),
('test_patient@test.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'patient', '+967771234222', TRUE, FALSE);

-- إضافة بيانات الأطباء الجدد
INSERT IGNORE INTO doctors (user_id, name, specialization, experience_years, license_number, latitude, longitude, is_available, rating) VALUES
(4, 'د. فاطمة أحمد', 'طب أطفال', 3, 'DOC789012', 15.3700, 44.1920, TRUE, 4.8),
(5, 'د. محمد علي', 'جراحة عامة', 8, 'DOC345678', 15.3680, 44.1900, FALSE, 4.2);

-- إضافة بيانات المرضى الجدد
INSERT IGNORE INTO patients (user_id, name, age, gender, address, emergency_contact) VALUES
(5, 'مريض تجريبي 2', 25, 'أنثى', 'صنعاء، اليمن', '+967771234333');

-- إضافة محافظ للمستخدمين الجدد
INSERT IGNORE INTO wallets (user_id, balance) VALUES
(4, 0.00),
(5, 200.00);

-- إضافة بعض طلبات الطوارئ التجريبية
INSERT IGNORE INTO emergency_requests (patient_id, patient_latitude, patient_longitude, patient_address, symptoms, urgency_level, status) VALUES
(2, 15.3700, 44.1920, 'صنعاء، اليمن', 'حمى شديدة وصداع', 'medium', 'pending'),
(1, 15.3680, 44.1900, 'صنعاء، اليمن', 'ألم في البطن', 'low', 'pending');

-- إضافة بعض المواعيد التجريبية
INSERT IGNORE INTO appointments (patient_id, doctor_id, appointment_date, appointment_time, reason, status) VALUES
(2, 2, '2024-02-05', '14:00:00', 'فحص دوري للأطفال', 'pending'),
(1, 3, '2024-02-10', '09:30:00', 'استشارة جراحية', 'pending');

SELECT 'تم إصلاح جدول المستخدمين وإضافة البيانات التجريبية بنجاح!' as message;
