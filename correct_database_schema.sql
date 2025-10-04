-- قاعدة بيانات تطبيق من قلب الطوارئ - الهيكل الصحيح
CREATE DATABASE IF NOT EXISTS emergency_heart_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE emergency_heart_db;

-- جدول المستخدمين الأساسي
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    user_type ENUM('patient', 'doctor', 'admin') NOT NULL,
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    is_blocked BOOLEAN DEFAULT FALSE
);

-- جدول المرضى
CREATE TABLE patients (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    age INT,
    gender ENUM('male', 'female'),
    address TEXT,
    medical_history TEXT,
    emergency_contact VARCHAR(20),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- جدول الأطباء
CREATE TABLE doctors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    specialization VARCHAR(100),
    experience_years INT,
    license_number VARCHAR(100),
    verification_status ENUM('pending', 'verified', 'rejected') DEFAULT 'pending',
    rating DECIMAL(3,2) DEFAULT 0.00,
    total_reviews INT DEFAULT 0,
    is_available BOOLEAN DEFAULT FALSE,
    current_latitude DECIMAL(10, 8),
    current_longitude DECIMAL(11, 8),
    base_price DECIMAL(10, 2) DEFAULT 50.00,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- جدول وثائق التحقق من الأطباء
CREATE TABLE doctor_documents (
    id INT AUTO_INCREMENT PRIMARY KEY,
    doctor_id INT NOT NULL,
    document_type ENUM('id_card', 'medical_license', 'academic_certificate', 'experience_certificate', 'profile_photo') NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    verification_status ENUM('pending', 'verified', 'rejected') DEFAULT 'pending',
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    verified_at TIMESTAMP NULL,
    verified_by INT NULL,
    FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE,
    FOREIGN KEY (verified_by) REFERENCES users(id)
);

-- جدول المحافظ الإلكترونية
CREATE TABLE wallets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    balance DECIMAL(10, 2) DEFAULT 0.00,
    total_earned DECIMAL(10, 2) DEFAULT 0.00,
    total_spent DECIMAL(10, 2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- جدول طلبات الاستدعاء
CREATE TABLE emergency_requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NULL,
    patient_latitude DECIMAL(10, 8) NOT NULL,
    patient_longitude DECIMAL(11, 8) NOT NULL,
    patient_address TEXT,
    symptoms TEXT,
    urgency_level ENUM('low', 'medium', 'high') DEFAULT 'medium',
    status ENUM('pending', 'accepted', 'on_way', 'arrived', 'completed', 'cancelled') DEFAULT 'pending',
    estimated_cost DECIMAL(10, 2),
    final_cost DECIMAL(10, 2),
    commission_rate DECIMAL(5, 2) DEFAULT 12.00,
    commission_amount DECIMAL(10, 2),
    distance_km DECIMAL(8, 2),
    estimated_arrival_time INT, -- بالدقائق
    request_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    accepted_time TIMESTAMP NULL,
    completed_time TIMESTAMP NULL,
    notes TEXT,
    FOREIGN KEY (patient_id) REFERENCES patients(id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(id)
);

-- جدول المعاملات المالية
CREATE TABLE transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    transaction_type ENUM('credit', 'debit', 'commission', 'withdrawal') NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    description TEXT,
    reference_id INT NULL, -- مرجع للطلب أو العملية المرتبطة
    reference_type ENUM('emergency_request', 'wallet_recharge', 'commission', 'withdrawal') NULL,
    status ENUM('pending', 'completed', 'failed') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- جدول التقييمات والمراجعات
CREATE TABLE reviews (
    id INT AUTO_INCREMENT PRIMARY KEY,
    emergency_request_id INT NOT NULL,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    rating INT CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (emergency_request_id) REFERENCES emergency_requests(id),
    FOREIGN KEY (patient_id) REFERENCES patients(id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(id)
);

-- جدول الإشعارات
CREATE TABLE notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type ENUM('emergency_request', 'payment', 'verification', 'general') NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    reference_id INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- جدول إعدادات النظام
CREATE TABLE system_settings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value TEXT NOT NULL,
    description TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- إدراج الإعدادات الافتراضية
INSERT INTO system_settings (setting_key, setting_value, description) VALUES
('commission_rate', '12.00', 'نسبة العمولة المئوية'),
('base_price_per_km', '5.00', 'السعر الأساسي لكل كيلومتر'),
('minimum_service_fee', '30.00', 'الحد الأدنى لرسوم الخدمة'),
('maximum_service_radius', '50', 'أقصى مسافة للخدمة بالكيلومتر'),
('app_name', 'من قلب الطوارئ', 'اسم التطبيق'),
('support_phone', '+967771234567', 'رقم الدعم الفني'),
('support_email', 'support@emergency-heart.com', 'بريد الدعم الفني');

-- إنشاء فهارس لتحسين الأداء
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_type ON users(user_type);
CREATE INDEX idx_doctors_available ON doctors(is_available);
CREATE INDEX idx_doctors_location ON doctors(current_latitude, current_longitude);
CREATE INDEX idx_emergency_requests_status ON emergency_requests(status);
CREATE INDEX idx_emergency_requests_patient ON emergency_requests(patient_id);
CREATE INDEX idx_emergency_requests_doctor ON emergency_requests(doctor_id);
CREATE INDEX idx_transactions_user ON transactions(user_id);
CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_read ON notifications(is_read);

-- إنشاء مستخدم مدير افتراضي
INSERT INTO users (email, password, user_type, phone) VALUES 
('admin@emergency-heart.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin', '+967771234567');

-- إنشاء محفظة للمدير
INSERT INTO wallets (user_id, balance) VALUES (1, 0.00);

-- إدراج بيانات تجريبية إضافية
INSERT INTO users (email, password, user_type, phone) VALUES
('doctor@doctor.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'doctor', '+967771234568'),
('patient@patient.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'patient', '+967771234569');

-- إدراج بيانات الأطباء
INSERT INTO doctors (user_id, name, specialization, experience_years, license_number, verification_status, rating, is_available, current_latitude, current_longitude, base_price) VALUES
(2, 'د. أحمد محمد', 'طب عام', 5, 'DOC123456', 'verified', 4.5, TRUE, 15.3694, 44.1910, 50.00);

-- إدراج بيانات المرضى
INSERT INTO patients (user_id, name, age, gender, address, medical_history, emergency_contact) VALUES
(3, 'مريض تجريبي', 30, 'male', 'صنعاء، اليمن', 'لا توجد أمراض مزمنة', '+967771234570');

-- إدراج محافظ للمستخدمين
INSERT INTO wallets (user_id, balance) VALUES
(2, 0.00),
(3, 150.00);

-- إدراج بعض طلبات الطوارئ التجريبية
INSERT INTO emergency_requests (patient_id, patient_latitude, patient_longitude, patient_address, symptoms, urgency_level, status, estimated_cost) VALUES
(1, 15.3694, 44.1910, 'صنعاء، اليمن', 'ألم في الصدر وصعوبة في التنفس', 'high', 'pending', 75.00);

-- إدراج بعض المعاملات التجريبية
INSERT INTO transactions (user_id, transaction_type, amount, description, reference_type, status) VALUES
(3, 'credit', 150.00, 'رصيد ابتدائي', 'wallet_recharge', 'completed'),
(3, 'debit', 50.00, 'دفع مقابل خدمة طبية', 'emergency_request', 'completed');

SELECT 'تم إنشاء قاعدة البيانات بالهيكل الصحيح بنجاح!' as message;
