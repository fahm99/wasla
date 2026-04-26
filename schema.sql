-- ============================================================
-- WASLA PLATFORM - UNIFIED DATABASE SCHEMA
-- منصة وصلة - قاعدة البيانات الموحدة
-- ============================================================
-- الملف الموحد: يجمع database.sql + database-security-updates.sql
-- الإصدار: 2.0 | تاريخ التوحيد: 2026-04-25
-- التنفيذ: قم بتشغيل هذا الملف مرة واحدة على Supabase / PostgreSQL
-- ملاحظة: CREATE OR REPLACE يضمن عدم التكرار
-- ============================================================

-- ============================================================
-- 1. ENUM TYPES
-- ============================================================

CREATE TYPE user_role AS ENUM ('STUDENT', 'PROVIDER', 'ADMIN');
CREATE TYPE user_status AS ENUM ('PENDING', 'ACTIVE', 'SUSPENDED', 'REJECTED');
CREATE TYPE institution_type AS ENUM ('UNIVERSITY', 'TRAINING_CENTER', 'INDEPENDENT', 'SCHOOL', 'INSTITUTE');
CREATE TYPE subscription_plan AS ENUM ('FREE', 'BASIC', 'PREMIUM');
CREATE TYPE course_status AS ENUM ('DRAFT', 'PUBLISHED', 'ARCHIVED');
CREATE TYPE course_level AS ENUM ('BEGINNER', 'INTERMEDIATE', 'ADVANCED');
CREATE TYPE lesson_type AS ENUM ('VIDEO', 'PDF', 'TEXT', 'FILE', 'IMAGE', 'AUDIO');
CREATE TYPE question_type AS ENUM ('MULTIPLE_CHOICE', 'TRUE_FALSE', 'TEXT');
CREATE TYPE notification_type AS ENUM ('INFO', 'WARNING', 'SUCCESS', 'ERROR', 'ANNOUNCEMENT');
CREATE TYPE payment_status AS ENUM ('PENDING', 'APPROVED', 'REJECTED', 'REFUNDED');
CREATE TYPE certificate_status AS ENUM ('ISSUED', 'REVOKED');
CREATE TYPE gender_type AS ENUM ('MALE', 'FEMALE');

-- ============================================================
-- 2. PROFILES TABLE (extends Supabase auth.users)
-- ============================================================

CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone TEXT,
    avatar TEXT,
    gender gender_type DEFAULT 'MALE',
    bio TEXT,
    role user_role DEFAULT 'STUDENT',
    status user_status DEFAULT 'PENDING',
    institution_type institution_type,
    institution_name TEXT,
    bank_account TEXT,
    bank_name TEXT,
    subscription_plan subscription_plan DEFAULT 'FREE',
    subscription_start_date TIMESTAMPTZ,
    subscription_end_date TIMESTAMPTZ,
    address TEXT,
    city TEXT,
    country TEXT DEFAULT 'Yemen',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_profiles_role ON public.profiles(role);
CREATE INDEX idx_profiles_status ON public.profiles(status);
CREATE INDEX idx_profiles_email ON public.profiles(email);
CREATE INDEX idx_profiles_institution_type ON public.profiles(institution_type);

-- ============================================================
-- 3. COURSES TABLE
-- ============================================================

CREATE TABLE public.courses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    short_description TEXT,
    price DECIMAL(10,2) DEFAULT 0,
    currency TEXT DEFAULT 'YER',
    level course_level DEFAULT 'BEGINNER',
    language TEXT DEFAULT 'ar',
    image TEXT,
    thumbnail TEXT,
    status course_status DEFAULT 'DRAFT',
    category TEXT,
    tags TEXT[],
    requirements TEXT[],
    objectives TEXT[],
    duration_minutes INTEGER DEFAULT 0,
    max_students INTEGER,
    certificate_enabled BOOLEAN DEFAULT TRUE,
    provider_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_courses_provider ON public.courses(provider_id);
CREATE INDEX idx_courses_status ON public.courses(status);
CREATE INDEX idx_courses_category ON public.courses(category);
CREATE INDEX idx_courses_level ON public.courses(level);
CREATE INDEX idx_courses_price ON public.courses(price);

-- ============================================================
-- 4. MODULES TABLE
-- ============================================================

CREATE TABLE public.modules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    "order" INTEGER DEFAULT 0,
    course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_modules_course ON public.modules(course_id);
CREATE INDEX idx_modules_order ON public.modules(course_id, "order");

-- ============================================================
-- 5. LESSONS TABLE
-- ============================================================

CREATE TABLE public.lessons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    type lesson_type DEFAULT 'TEXT',
    content TEXT DEFAULT '',
    file_url TEXT,
    file_name TEXT,
    file_size BIGINT DEFAULT 0,
    duration INTEGER DEFAULT 0,
    is_free BOOLEAN DEFAULT FALSE,
    "order" INTEGER DEFAULT 0,
    module_id UUID NOT NULL REFERENCES public.modules(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_lessons_module ON public.lessons(module_id);
CREATE INDEX idx_lessons_order ON public.lessons(module_id, "order");
CREATE INDEX idx_lessons_type ON public.lessons(type);

-- ============================================================
-- 6. EXAMS TABLE
-- ============================================================

CREATE TABLE public.exams (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    passing_score INTEGER DEFAULT 60,
    duration INTEGER DEFAULT 30,
    max_attempts INTEGER DEFAULT 3,
    shuffle_questions BOOLEAN DEFAULT FALSE,
    show_results BOOLEAN DEFAULT TRUE,
    course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
    module_id UUID REFERENCES public.modules(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_exams_course ON public.exams(course_id);
CREATE INDEX idx_exams_module ON public.exams(module_id);

-- ============================================================
-- 7. QUESTIONS TABLE
-- ============================================================

CREATE TABLE public.questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    text TEXT NOT NULL,
    type question_type DEFAULT 'MULTIPLE_CHOICE',
    points INTEGER DEFAULT 1,
    explanation TEXT,
    image_url TEXT,
    "order" INTEGER DEFAULT 0,
    exam_id UUID NOT NULL REFERENCES public.exams(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_questions_exam ON public.questions(exam_id);
CREATE INDEX idx_questions_order ON public.questions(exam_id, "order");

-- ============================================================
-- 8. ANSWERS TABLE
-- ============================================================

CREATE TABLE public.answers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    text TEXT NOT NULL,
    is_correct BOOLEAN DEFAULT FALSE,
    question_id UUID NOT NULL REFERENCES public.questions(id) ON DELETE CASCADE
);

CREATE INDEX idx_answers_question ON public.answers(question_id);

-- ============================================================
-- 9. ENROLLMENTS TABLE
-- ============================================================

CREATE TABLE public.enrollments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    progress INTEGER DEFAULT 0 CHECK (progress >= 0 AND progress <= 100),
    enrolled_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    last_accessed_at TIMESTAMPTZ DEFAULT NOW(),
    student_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
    UNIQUE(student_id, course_id)
);

CREATE INDEX idx_enrollments_student ON public.enrollments(student_id);
CREATE INDEX idx_enrollments_course ON public.enrollments(course_id);

-- ============================================================
-- 10. LESSON PROGRESS TABLE
-- ============================================================

CREATE TABLE public.lesson_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMPTZ,
    watch_progress DECIMAL(5,2) DEFAULT 0 CHECK (watch_progress >= 0 AND watch_progress <= 100),
    student_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    lesson_id UUID NOT NULL REFERENCES public.lessons(id) ON DELETE CASCADE,
    UNIQUE(student_id, lesson_id)
);

CREATE INDEX idx_lesson_progress_student ON public.lesson_progress(student_id);
CREATE INDEX idx_lesson_progress_lesson ON public.lesson_progress(lesson_id);

-- ============================================================
-- 11. EXAM ATTEMPTS TABLE
-- ============================================================

CREATE TABLE public.exam_attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    score INTEGER DEFAULT 0,
    total_points INTEGER DEFAULT 0,
    passed BOOLEAN DEFAULT FALSE,
    student_answers JSONB DEFAULT '{}',
    time_spent INTEGER DEFAULT 0,
    completed_at TIMESTAMPTZ DEFAULT NOW(),
    student_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    exam_id UUID NOT NULL REFERENCES public.exams(id) ON DELETE CASCADE
);

CREATE INDEX idx_exam_attempts_student ON public.exam_attempts(student_id);
CREATE INDEX idx_exam_attempts_exam ON public.exam_attempts(exam_id);

-- ============================================================
-- 12. CERTIFICATES TABLE
-- ============================================================

CREATE TABLE public.certificates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    certificate_number TEXT UNIQUE,
    certificate_url TEXT,
    student_name TEXT NOT NULL,
    course_name TEXT NOT NULL,
    provider_name TEXT NOT NULL,
    score INTEGER,
    issued_at TIMESTAMPTZ DEFAULT NOW(),
    template_name TEXT,
    template_data JSONB DEFAULT '{}',
    status certificate_status DEFAULT 'ISSUED',
    student_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
    provider_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE
);

CREATE INDEX idx_certificates_student ON public.certificates(student_id);
CREATE INDEX idx_certificates_course ON public.certificates(course_id);
CREATE INDEX idx_certificates_provider ON public.certificates(provider_id);
CREATE INDEX idx_certificates_number ON public.certificates(certificate_number);

-- ============================================================
-- 13. CERTIFICATE TEMPLATES TABLE
-- ============================================================

CREATE TABLE public.certificate_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    background_color TEXT DEFAULT '#ffffff',
    text_color TEXT DEFAULT '#000000',
    accent_color TEXT DEFAULT '#0c1445',
    logo_url TEXT,
    signature_url TEXT,
    signature_name TEXT,
    signature_title TEXT,
    seal_url TEXT,
    template_config JSONB DEFAULT '{}',
    is_default BOOLEAN DEFAULT FALSE,
    provider_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE
);

CREATE INDEX idx_cert_templates_provider ON public.certificate_templates(provider_id);

-- ============================================================
-- 14. NOTIFICATIONS TABLE
-- ============================================================

CREATE TABLE public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type notification_type DEFAULT 'INFO',
    sent_to_all BOOLEAN DEFAULT FALSE,
    target_roles user_role[],
    read_at TIMESTAMPTZ,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    sender_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_notifications_user ON public.notifications(user_id);
CREATE INDEX idx_notifications_read ON public.notifications(user_id, read_at);

-- ============================================================
-- 15. PAYMENTS TABLE
-- ============================================================

CREATE TABLE public.payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    amount DECIMAL(12,2) NOT NULL,
    currency TEXT DEFAULT 'YER',
    payment_method TEXT,
    transaction_ref TEXT UNIQUE,
    status payment_status DEFAULT 'PENDING',
    description TEXT,
    proof_url TEXT,
    provider_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    processed_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    processed_at TIMESTAMPTZ
);

CREATE INDEX idx_payments_provider ON public.payments(provider_id);
CREATE INDEX idx_payments_status ON public.payments(status);

-- ============================================================
-- 16. RATINGS TABLE
-- ============================================================

CREATE TABLE public.ratings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review TEXT,
    student_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(student_id, course_id)
);

CREATE INDEX idx_ratings_course ON public.ratings(course_id);
CREATE INDEX idx_ratings_student ON public.ratings(student_id);

-- ============================================================
-- 17. ANNOUNCEMENTS TABLE
-- ============================================================

CREATE TABLE public.announcements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    image_url TEXT,
    link_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    target_roles user_role[] DEFAULT '{"STUDENT"}',
    start_date TIMESTAMPTZ DEFAULT NOW(),
    end_date TIMESTAMPTZ,
    created_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 18. SUPPORT TICKETS TABLE
-- ============================================================

CREATE TABLE public.support_tickets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subject TEXT NOT NULL,
    message TEXT NOT NULL,
    status TEXT DEFAULT 'OPEN' CHECK (status IN ('OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED')),
    priority TEXT DEFAULT 'MEDIUM' CHECK (priority IN ('LOW', 'MEDIUM', 'HIGH', 'URGENT')),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    assigned_to UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_tickets_user ON public.support_tickets(user_id);
CREATE INDEX idx_tickets_status ON public.support_tickets(status);

-- ============================================================
-- 19. TICKET REPLIES TABLE
-- ============================================================

CREATE TABLE public.ticket_replies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message TEXT NOT NULL,
    is_admin BOOLEAN DEFAULT FALSE,
    attachment_url TEXT,
    ticket_id UUID NOT NULL REFERENCES public.support_tickets(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 20. SYSTEM SETTINGS TABLE
-- ============================================================

CREATE TABLE public.system_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    key TEXT UNIQUE NOT NULL,
    value TEXT NOT NULL,
    description TEXT,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO public.system_settings (key, value, description) VALUES
('subscription_fee_basic', '500000', 'Basic subscription fee in YER'),
('subscription_fee_premium', '1000000', 'Premium subscription fee in YER'),
('platform_commission_rate', '10', 'Platform commission rate percentage'),
('min_withdraw_amount', '50000', 'Minimum withdrawal amount in YER'),
('max_course_file_size_mb', '500', 'Maximum course file size in MB'),
('allowed_file_types', 'mp4,pdf,zip,doc,docx,ppt,pptx,jpg,png,jpeg,gif,mp3,wav', 'Allowed file types for upload'),
('platform_name', 'وصلة', 'Platform display name'),
('platform_email', 'admin@wasla.com', 'Platform contact email'),
('auto_approve_providers', 'false', 'Auto approve new provider accounts');

-- ============================================================
-- STORAGE BUCKETS
-- ============================================================

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types) VALUES
('avatars', 'avatars', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp']);

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types) VALUES
('course-images', 'course-images', true, 10485760, ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp']);

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types) VALUES
('course-videos', 'course-videos', false, 524288000, ARRAY['video/mp4', 'video/webm', 'video/quicktime', 'video/x-msvideo']);

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types) VALUES
('course-files', 'course-files', false, 104857600, ARRAY['application/pdf', 'application/zip', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'application/vnd.ms-powerpoint', 'application/vnd.openxmlformats-officedocument.presentationml.presentation', 'text/plain']);

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types) VALUES
('course-audio', 'course-audio', false, 52428800, ARRAY['audio/mpeg', 'audio/wav', 'audio/ogg']);

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types) VALUES
('certificates', 'certificates', true, 10485760, ARRAY['image/jpeg', 'image/png', 'application/pdf']);

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types) VALUES
('provider-documents', 'provider-documents', false, 10485760, ARRAY['image/jpeg', 'image/png', 'application/pdf']);

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types) VALUES
('payment-proofs', 'payment-proofs', false, 10485760, ARRAY['image/jpeg', 'image/png', 'application/pdf']);

INSERT INTO storage.buckets (id, name, public, file_size_limit) VALUES
('general', 'general', true, 104857600);

-- ============================================================
-- STORAGE POLICIES
-- ============================================================

-- === Avatars ===
CREATE POLICY "Users can upload their own avatar" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'avatars' 
        AND auth.uid() IS NOT NULL
        AND (storage.foldername(name))[1] = auth.uid()::text
    );

CREATE POLICY "Anyone can view avatars" ON storage.objects
    FOR SELECT USING (bucket_id = 'avatars');

CREATE POLICY "Users can update their own avatar" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'avatars' 
        AND (storage.foldername(name))[1] = auth.uid()::text
    );

CREATE POLICY "Users can delete their own avatar" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'avatars' 
        AND (storage.foldername(name))[1] = auth.uid()::text
    );

-- === Course Images ===
CREATE POLICY "Providers can upload course images" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'course-images' AND
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'PROVIDER')
    );

CREATE POLICY "Anyone can view course images" ON storage.objects
    FOR SELECT USING (bucket_id = 'course-images');

CREATE POLICY "Providers can update course images" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'course-images' AND
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'PROVIDER')
    );

CREATE POLICY "Providers can delete course images" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'course-images' AND
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'PROVIDER')
    );

-- === Course Videos ===
CREATE POLICY "Providers can upload course videos" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'course-videos' AND
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'PROVIDER')
    );

CREATE POLICY "Authenticated users can view course videos" ON storage.objects
    FOR SELECT USING (
        bucket_id = 'course-videos' AND auth.uid() IS NOT NULL
    );

CREATE POLICY "Providers can update course videos" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'course-videos' AND
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'PROVIDER')
    );

CREATE POLICY "Providers can delete course videos" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'course-videos' AND
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'PROVIDER')
    );

-- === Course Files ===
CREATE POLICY "Providers can upload course files" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'course-files' AND
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'PROVIDER')
    );

CREATE POLICY "Authenticated users can view course files" ON storage.objects
    FOR SELECT USING (
        bucket_id = 'course-files' AND auth.uid() IS NOT NULL
    );

CREATE POLICY "Providers can update course files" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'course-files' AND
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'PROVIDER')
    );

CREATE POLICY "Providers can delete course files" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'course-files' AND
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'PROVIDER')
    );

-- === Course Audio ===
CREATE POLICY "Providers can upload course audio" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'course-audio' AND
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'PROVIDER')
    );

CREATE POLICY "Authenticated users can view course audio" ON storage.objects
    FOR SELECT USING (
        bucket_id = 'course-audio' AND auth.uid() IS NOT NULL
    );

-- === Certificates ===
CREATE POLICY "Providers can upload certificates" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'certificates' AND
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'PROVIDER')
    );

CREATE POLICY "Anyone can view certificates" ON storage.objects
    FOR SELECT USING (bucket_id = 'certificates');

-- === Provider Documents ===
CREATE POLICY "Providers can upload their documents" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'provider-documents' AND
        auth.uid() IS NOT NULL
    );

CREATE POLICY "Admins can view provider documents" ON storage.objects
    FOR SELECT USING (
        bucket_id = 'provider-documents' AND
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'ADMIN')
    );

CREATE POLICY "Admins can delete provider documents" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'provider-documents' AND
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'ADMIN')
    );

-- === Payment Proofs ===
CREATE POLICY "Providers can upload payment proofs" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'payment-proofs' AND
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'PROVIDER')
    );

CREATE POLICY "Admins can view payment proofs" ON storage.objects
    FOR SELECT USING (
        bucket_id = 'payment-proofs' AND
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'ADMIN')
    );

-- === General ===
CREATE POLICY "Authenticated users can upload to general" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'general' AND auth.uid() IS NOT NULL
    );

CREATE POLICY "Anyone can view general files" ON storage.objects
    FOR SELECT USING (bucket_id = 'general');

-- ============================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exams ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.answers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lesson_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exam_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.certificates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.certificate_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ratings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.announcements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.support_tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ticket_replies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.system_settings ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- PROFILES RLS POLICIES
-- ============================================================

CREATE POLICY "Public profiles are viewable by everyone" ON public.profiles
    FOR SELECT USING (status = 'ACTIVE' OR id = auth.uid());

CREATE POLICY "Users can insert their own profile" ON public.profiles
    FOR INSERT WITH CHECK (id = auth.uid());

CREATE POLICY "Users can update their own profile" ON public.profiles
    FOR UPDATE USING (id = auth.uid());

CREATE POLICY "Admins can update any profile" ON public.profiles
    FOR UPDATE USING (
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'ADMIN')
    );

CREATE POLICY "Admins can view all profiles" ON public.profiles
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'ADMIN') OR
        status = 'ACTIVE' OR
        id = auth.uid()
    );

-- ============================================================
-- COURSES RLS POLICIES
-- ============================================================

CREATE POLICY "Published courses are viewable by everyone" ON public.courses
    FOR SELECT USING (status = 'PUBLISHED');

CREATE POLICY "Providers can view own courses" ON public.courses
    FOR SELECT USING (
        provider_id = auth.uid() OR
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'ADMIN')
    );

CREATE POLICY "Providers can create courses" ON public.courses
    FOR INSERT WITH CHECK (
        provider_id = auth.uid() AND
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'PROVIDER' AND status = 'ACTIVE')
    );

CREATE POLICY "Providers can update own courses" ON public.courses
    FOR UPDATE USING (provider_id = auth.uid());

CREATE POLICY "Providers can delete own courses" ON public.courses
    FOR DELETE USING (provider_id = auth.uid());

CREATE POLICY "Admins can manage all courses" ON public.courses
    FOR ALL USING (
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'ADMIN')
    );

-- ============================================================
-- MODULES RLS POLICIES
-- ============================================================

CREATE POLICY "Anyone can view modules of published courses" ON public.modules
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM public.courses WHERE id = course_id AND status = 'PUBLISHED') OR
        EXISTS (SELECT 1 FROM public.courses WHERE id = course_id AND provider_id = auth.uid()) OR
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'ADMIN')
    );

CREATE POLICY "Course providers can manage modules" ON public.modules
    FOR ALL USING (
        EXISTS (SELECT 1 FROM public.courses WHERE id = course_id AND provider_id = auth.uid()) OR
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'ADMIN')
    );

-- ============================================================
-- LESSONS RLS POLICIES
-- ============================================================

CREATE POLICY "Anyone can view lessons of published courses" ON public.lessons
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM public.courses WHERE id = (SELECT course_id FROM public.modules WHERE id = module_id) AND status = 'PUBLISHED') OR
        EXISTS (SELECT 1 FROM public.courses c JOIN public.modules m ON m.id = lessons.module_id WHERE c.id = m.course_id AND c.provider_id = auth.uid()) OR
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'ADMIN')
    );

CREATE POLICY "Course providers can manage lessons" ON public.lessons
    FOR ALL USING (
        EXISTS (SELECT 1 FROM public.modules m JOIN public.courses c ON c.id = m.course_id WHERE m.id = module_id AND c.provider_id = auth.uid()) OR
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'ADMIN')
    );

-- ============================================================
-- EXAMS RLS POLICIES
-- ============================================================

CREATE POLICY "Anyone can view exams of published courses" ON public.exams
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM public.courses WHERE id = course_id AND status = 'PUBLISHED') OR
        EXISTS (SELECT 1 FROM public.courses WHERE id = course_id AND provider_id = auth.uid()) OR
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'ADMIN')
    );

CREATE POLICY "Course providers can manage exams" ON public.exams
    FOR ALL USING (
        EXISTS (SELECT 1 FROM public.courses WHERE id = course_id AND provider_id = auth.uid()) OR
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'ADMIN')
    );

-- ============================================================
-- QUESTIONS RLS POLICIES
-- ============================================================

CREATE POLICY "Enrolled students or providers can view questions" ON public.questions
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM public.exams e JOIN public.courses c ON c.id = e.course_id WHERE e.id = exam_id AND c.provider_id = auth.uid()) OR
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'ADMIN') OR
        EXISTS (SELECT 1 FROM public.enrollments en JOIN public.exams e ON e.course_id = en.course_id WHERE e.id = exam_id AND en.student_id = auth.uid())
    );

CREATE POLICY "Exam providers can manage questions" ON public.questions
    FOR ALL USING (
        EXISTS (SELECT 1 FROM public.exams e JOIN public.courses c ON c.id = e.course_id WHERE e.id = exam_id AND c.provider_id = auth.uid()) OR
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'ADMIN')
    );

-- ============================================================
-- ANSWERS RLS POLICIES
-- ============================================================

CREATE POLICY "Related users can view answers" ON public.answers
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM public.questions q JOIN public.exams e ON e.id = q.exam_id JOIN public.courses c ON c.id = e.course_id WHERE q.id = question_id AND c.provider_id = auth.uid()) OR
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'ADMIN') OR
        EXISTS (SELECT 1 FROM public.enrollments en JOIN public.exams e ON e.course_id = en.course_id JOIN public.questions q ON q.exam_id = e.id WHERE q.id = question_id AND en.student_id = auth.uid())
    );

CREATE POLICY "Exam providers can manage answers" ON public.answers
    FOR ALL USING (
        EXISTS (SELECT 1 FROM public.questions q JOIN public.exams e ON e.id = q.exam_id JOIN public.courses c ON c.id = e.course_id WHERE q.id = question_id AND c.provider_id = auth.uid()) OR
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'ADMIN')
    );

-- ============================================================
-- ENROLLMENTS RLS POLICIES
-- ============================================================

CREATE POLICY "Students can view own enrollments" ON public.enrollments
    FOR SELECT USING (student_id = auth.uid());

CREATE POLICY "Providers can view course enrollments" ON public.enrollments
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM public.courses WHERE id = course_id AND provider_id = auth.uid())
    );

CREATE POLICY "Admins can view all enrollments" ON public.enrollments
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'ADMIN')
    );

CREATE POLICY "Students can create enrollments" ON public.enrollments
    FOR INSERT WITH CHECK (student_id = auth.uid());

CREATE POLICY "Students can update own enrollments" ON public.enrollments
    FOR UPDATE USING (student_id = auth.uid());

-- ============================================================
-- LESSON PROGRESS RLS POLICIES
-- ============================================================

CREATE POLICY "Users can manage own lesson progress" ON public.lesson_progress
    FOR ALL USING (student_id = auth.uid());

-- ============================================================
-- EXAM ATTEMPTS RLS POLICIES
-- ============================================================

CREATE POLICY "Students can view own exam attempts" ON public.exam_attempts
    FOR SELECT USING (student_id = auth.uid());

CREATE POLICY "Providers can view course exam attempts" ON public.exam_attempts
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM public.exams WHERE id = exam_id AND
            EXISTS (SELECT 1 FROM public.courses WHERE id = course_id AND provider_id = auth.uid()))
    );

CREATE POLICY "Students can create exam attempts" ON public.exam_attempts
    FOR INSERT WITH CHECK (student_id = auth.uid());

-- ============================================================
-- CERTIFICATES RLS POLICIES
-- ============================================================

CREATE POLICY "Users can view own certificates" ON public.certificates
    FOR SELECT USING (student_id = auth.uid() OR provider_id = auth.uid());

CREATE POLICY "Providers can manage course certificates" ON public.certificates
    FOR ALL USING (
        provider_id = auth.uid() OR
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'ADMIN')
    );

-- ============================================================
-- CERTIFICATE TEMPLATES RLS POLICIES
-- ============================================================

CREATE POLICY "Providers can manage own templates" ON public.certificate_templates
    FOR ALL USING (provider_id = auth.uid());

-- ============================================================
-- NOTIFICATIONS RLS POLICIES
-- ============================================================

CREATE POLICY "Users can view own notifications" ON public.notifications
    FOR SELECT USING (user_id = auth.uid() OR sent_to_all = true);

CREATE POLICY "Admins can create notifications" ON public.notifications
    FOR INSERT WITH CHECK (
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'ADMIN')
    );

CREATE POLICY "Users can update own notifications" ON public.notifications
    FOR UPDATE USING (user_id = auth.uid());

-- ============================================================
-- PAYMENTS RLS POLICIES
-- ============================================================

CREATE POLICY "Providers can view own payments" ON public.payments
    FOR SELECT USING (provider_id = auth.uid());

CREATE POLICY "Admins can manage all payments" ON public.payments
    FOR ALL USING (
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'ADMIN')
    );

CREATE POLICY "Providers can create payments" ON public.payments
    FOR INSERT WITH CHECK (
        provider_id = auth.uid() AND
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'PROVIDER')
    );

-- ============================================================
-- RATINGS RLS POLICIES
-- ============================================================

CREATE POLICY "Anyone can view ratings" ON public.ratings
    FOR SELECT USING (true);

CREATE POLICY "Students can create ratings" ON public.ratings
    FOR INSERT WITH CHECK (
        student_id = auth.uid() AND
        EXISTS (SELECT 1 FROM public.enrollments WHERE student_id = auth.uid() AND course_id = ratings.course_id)
    );

-- ============================================================
-- SYSTEM SETTINGS RLS
-- ============================================================

CREATE POLICY "Anyone can read system settings" ON public.system_settings
    FOR SELECT USING (true);

CREATE POLICY "Admins can manage system settings" ON public.system_settings
    FOR ALL USING (
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'ADMIN')
    );

-- ============================================================
-- FUNCTIONS AND PROCEDURES
-- ============================================================

-- Auto-create profile on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$ BEGIN
    INSERT INTO public.profiles (id, name, email, role, status)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'name', NEW.email),
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'role', 'STUDENT')::user_role,
        CASE
            WHEN COALESCE(NEW.raw_user_meta_data->>'role', 'STUDENT') = 'STUDENT' THEN 'ACTIVE'
            ELSE 'PENDING'
        END
    );
    RETURN NEW;
END;
 $$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$ BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
 $$ LANGUAGE plpgsql;

CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_courses_updated_at
    BEFORE UPDATE ON public.courses
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_modules_updated_at
    BEFORE UPDATE ON public.modules
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_lessons_updated_at
    BEFORE UPDATE ON public.lessons
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_exams_updated_at
    BEFORE UPDATE ON public.exams
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================================
-- DATABASE FUNCTIONS
-- ============================================================

-- Get dashboard stats for provider
CREATE OR REPLACE FUNCTION public.get_provider_stats(p_provider_id UUID)
RETURNS JSON AS $$ DECLARE
    v_stats JSON;
BEGIN
    SELECT json_build_object(
        'total_courses', (SELECT COUNT(*) FROM public.courses WHERE provider_id = p_provider_id),
        'published_courses', (SELECT COUNT(*) FROM public.courses WHERE provider_id = p_provider_id AND status = 'PUBLISHED'),
        'draft_courses', (SELECT COUNT(*) FROM public.courses WHERE provider_id = p_provider_id AND status = 'DRAFT'),
        'total_students', (SELECT COUNT(DISTINCT e.student_id) FROM public.enrollments e
            JOIN public.courses c ON c.id = e.course_id WHERE c.provider_id = p_provider_id),
        'total_certificates', (SELECT COUNT(*) FROM public.certificates WHERE provider_id = p_provider_id),
        'total_revenue', (SELECT COALESCE(SUM(price), 0) FROM public.courses WHERE provider_id = p_provider_id),
        'total_ratings', (SELECT COALESCE(AVG(rating), 0) FROM public.ratings r
            JOIN public.courses c ON c.id = r.course_id WHERE c.provider_id = p_provider_id)
    ) INTO v_stats;
    RETURN v_stats;
END;
 $$ LANGUAGE plpgsql SECURITY DEFINER;

-- Get dashboard stats for admin
CREATE OR REPLACE FUNCTION public.get_admin_stats()
RETURNS JSON AS $$ DECLARE
    v_stats JSON;
BEGIN
    SELECT json_build_object(
        'total_providers', (SELECT COUNT(*) FROM public.profiles WHERE role = 'PROVIDER'),
        'active_providers', (SELECT COUNT(*) FROM public.profiles WHERE role = 'PROVIDER' AND status = 'ACTIVE'),
        'pending_providers', (SELECT COUNT(*) FROM public.profiles WHERE role = 'PROVIDER' AND status = 'PENDING'),
        'suspended_providers', (SELECT COUNT(*) FROM public.profiles WHERE role = 'PROVIDER' AND status = 'SUSPENDED'),
        'total_students', (SELECT COUNT(*) FROM public.profiles WHERE role = 'STUDENT'),
        'active_students', (SELECT COUNT(*) FROM public.profiles WHERE role = 'STUDENT' AND status = 'ACTIVE'),
        'total_courses', (SELECT COUNT(*) FROM public.courses),
        'published_courses', (SELECT COUNT(*) FROM public.courses WHERE status = 'PUBLISHED'),
        'total_enrollments', (SELECT COUNT(*) FROM public.enrollments),
        'total_certificates', (SELECT COUNT(*) FROM public.certificates),
        'total_revenue', (SELECT COALESCE(SUM(amount), 0) FROM public.payments WHERE status = 'APPROVED'),
        'pending_payments', (SELECT COUNT(*) FROM public.payments WHERE status = 'PENDING')
    ) INTO v_stats;
    RETURN v_stats;
END;
 $$ LANGUAGE plpgsql SECURITY DEFINER;

-- Get student stats
CREATE OR REPLACE FUNCTION public.get_student_stats(p_student_id UUID)
RETURNS JSON AS $$ DECLARE
    v_stats JSON;
BEGIN
    SELECT json_build_object(
        'total_enrollments', (SELECT COUNT(*) FROM public.enrollments WHERE student_id = p_student_id),
        'completed_courses', (SELECT COUNT(*) FROM public.enrollments WHERE student_id = p_student_id AND completed_at IS NOT NULL),
        'in_progress', (SELECT COUNT(*) FROM public.enrollments WHERE student_id = p_student_id AND completed_at IS NULL),
        'total_certificates', (SELECT COUNT(*) FROM public.certificates WHERE student_id = p_student_id),
        'avg_score', (SELECT COALESCE(AVG(score), 0) FROM public.exam_attempts WHERE student_id = p_student_id)
    ) INTO v_stats;
    RETURN v_stats;
END;
 $$ LANGUAGE plpgsql SECURITY DEFINER;

-- Enroll student in course
CREATE OR REPLACE FUNCTION public.enroll_in_course(
    p_student_id UUID,
    p_course_id UUID
)
RETURNS JSON AS $$ DECLARE
    v_enrollment_id UUID;
    v_course RECORD;
BEGIN
    SELECT * INTO v_course FROM public.courses WHERE id = p_course_id AND status = 'PUBLISHED';
    IF NOT FOUND THEN
        RETURN json_build_object('success', false, 'message', 'Course not found or not published');
    END IF;

    IF EXISTS (SELECT 1 FROM public.enrollments WHERE student_id = p_student_id AND course_id = p_course_id) THEN
        RETURN json_build_object('success', false, 'message', 'Already enrolled');
    END IF;

    INSERT INTO public.enrollments (student_id, course_id)
    VALUES (p_student_id, p_course_id)
    RETURNING id INTO v_enrollment_id;

    RETURN json_build_object('success', true, 'enrollment_id', v_enrollment_id);
END;
 $$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update enrollment progress
CREATE OR REPLACE FUNCTION public.update_enrollment_progress(p_enrollment_id UUID)
RETURNS VOID AS $$ DECLARE
    v_course_id UUID;
    v_student_id UUID;
    v_total_lessons INTEGER;
    v_completed_lessons INTEGER;
    v_progress INTEGER;
BEGIN
    SELECT course_id, student_id INTO v_course_id, v_student_id
    FROM public.enrollments WHERE id = p_enrollment_id;

    SELECT COUNT(*) INTO v_total_lessons
    FROM public.lessons l
    JOIN public.modules m ON m.id = l.module_id
    WHERE m.course_id = v_course_id;

    SELECT COUNT(*) INTO v_completed_lessons
    FROM public.lesson_progress lp
    JOIN public.lessons l ON l.id = lp.lesson_id
    JOIN public.modules m ON m.id = l.module_id
    WHERE m.course_id = v_course_id AND lp.student_id = v_student_id AND lp.completed = true;

    IF v_total_lessons > 0 THEN
        v_progress := (v_completed_lessons * 100) / v_total_lessons;
    ELSE
        v_progress := 0;
    END IF;

    UPDATE public.enrollments SET
        progress = v_progress,
        last_accessed_at = NOW(),
        completed_at = CASE WHEN v_progress >= 100 THEN NOW() ELSE NULL END
    WHERE id = p_enrollment_id;
END;
 $$ LANGUAGE plpgsql SECURITY DEFINER;

-- Submit exam attempt
CREATE OR REPLACE FUNCTION public.submit_exam_attempt(
    p_student_id UUID,
    p_exam_id UUID,
    p_answers JSONB,
    p_time_spent INTEGER DEFAULT 0
)
RETURNS JSON AS $$ DECLARE
    v_score INTEGER := 0;
    v_total_points INTEGER := 0;
    v_passing_score INTEGER;
    v_max_attempts INTEGER;
    v_attempt_count INTEGER;
    v_attempt_id UUID;
BEGIN
    SELECT passing_score, max_attempts INTO v_passing_score, v_max_attempts
    FROM public.exams WHERE id = p_exam_id;
    IF NOT FOUND THEN
        RETURN json_build_object('success', false, 'message', 'Exam not found');
    END IF;

    SELECT COUNT(*) INTO v_attempt_count FROM public.exam_attempts WHERE student_id = p_student_id AND exam_id = p_exam_id;
    IF v_attempt_count >= v_max_attempts THEN
        RETURN json_build_object('success', false, 'message', 'Max attempts reached');
    END IF;

    SELECT COALESCE(SUM(q.points), 0) INTO v_total_points
    FROM public.questions q WHERE q.exam_id = p_exam_id;

    SELECT COALESCE(SUM(q.points), 0) INTO v_score
    FROM public.questions q
    LEFT JOIN public.answers a ON a.question_id = q.id AND a.is_correct = true
    WHERE q.exam_id = p_exam_id
    AND (
        (q.type = 'MULTIPLE_CHOICE' AND a.id::text = (p_answers->>q.id::text))
        OR
        (q.type = 'TRUE_FALSE' AND (p_answers->>q.id::text)::boolean = (a.text::boolean))
    );

    INSERT INTO public.exam_attempts (student_id, exam_id, score, total_points, passed, student_answers, time_spent)
    VALUES (p_student_id, p_exam_id, v_score, v_total_points, (v_score * 100 / GREATEST(v_total_points, 1)) >= v_passing_score, p_answers, p_time_spent)
    RETURNING id INTO v_attempt_id;

    RETURN json_build_object(
        'success', true,
        'attempt_id', v_attempt_id,
        'score', v_score,
        'total_points', v_total_points,
        'percentage', (v_score * 100 / GREATEST(v_total_points, 1)),
        'passed', (v_score * 100 / GREATEST(v_total_points, 1)) >= v_passing_score
    );
END;
 $$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create sequence for certificate numbers
CREATE SEQUENCE IF NOT EXISTS certificate_seq START 1;

-- Issue certificate
CREATE OR REPLACE FUNCTION public.issue_certificate(
    p_student_id UUID,
    p_course_id UUID,
    p_provider_id UUID,
    p_template_id UUID DEFAULT NULL,
    p_score INTEGER DEFAULT NULL
)
RETURNS JSON AS $$ DECLARE
    v_cert_id UUID;
    v_cert_number TEXT;
    v_student_name TEXT;
    v_course_title TEXT;
    v_provider_name TEXT;
    v_template_name TEXT;
BEGIN
    SELECT p.name INTO v_student_name FROM public.profiles p WHERE p.id = p_student_id;
    SELECT c.title INTO v_course_title FROM public.courses c WHERE c.id = p_course_id;
    SELECT p.name INTO v_provider_name FROM public.profiles p WHERE p.id = p_provider_id;

    IF p_template_id IS NOT NULL THEN
        SELECT name INTO v_template_name FROM public.certificate_templates WHERE id = p_template_id;
    END IF;

    v_cert_number := 'WASLA-' || to_char(NOW(), 'YYYYMMDD') || '-' || LPAD(nextval('certificate_seq')::text, 6, '0');

    INSERT INTO public.certificates (
        certificate_number, student_name, course_name, provider_name,
        score, template_name, student_id, course_id, provider_id
    ) VALUES (
        v_cert_number, v_student_name, v_course_title, v_provider_name,
        p_score, v_template_name, p_student_id, p_course_id, p_provider_id
    ) RETURNING id INTO v_cert_id;

    RETURN json_build_object(
        'success', true,
        'certificate_id', v_cert_id,
        'certificate_number', v_cert_number,
        'student_name', v_student_name,
        'course_name', v_course_title,
        'provider_name', v_provider_name
    );
END;
 $$ LANGUAGE plpgsql SECURITY DEFINER;

-- Monthly stats for admin charts
CREATE OR REPLACE FUNCTION public.get_monthly_stats(p_months INTEGER DEFAULT 12)
RETURNS JSON AS $$ DECLARE
    v_result JSON;
BEGIN
    SELECT json_agg(
        json_build_object(
            'month', month_label,
            'providers', provider_count,
            'students', student_count,
            'courses', course_count,
            'enrollments', enrollment_count,
            'revenue', revenue
        )
    ) INTO v_result
    FROM (
        SELECT
            to_char(d, 'YYYY-MM') AS month_label,
            (SELECT COUNT(*) FROM public.profiles WHERE role = 'PROVIDER' AND created_at BETWEEN d AND d + INTERVAL '1 month') AS provider_count,
            (SELECT COUNT(*) FROM public.profiles WHERE role = 'STUDENT' AND created_at BETWEEN d AND d + INTERVAL '1 month') AS student_count,
            (SELECT COUNT(*) FROM public.courses WHERE created_at BETWEEN d AND d + INTERVAL '1 month') AS course_count,
            (SELECT COUNT(*) FROM public.enrollments WHERE enrolled_at BETWEEN d AND d + INTERVAL '1 month') AS enrollment_count,
            (SELECT COALESCE(SUM(amount), 0) FROM public.payments WHERE status = 'APPROVED' AND created_at BETWEEN d AND d + INTERVAL '1 month') AS revenue
        FROM generate_series(
            date_trunc('month', NOW()) - (p_months || ' months')::interval,
            date_trunc('month', NOW()),
            '1 month'::interval
        ) d
    ) monthly_data;
    RETURN COALESCE(v_result, '[]'::JSON);
END;
 $$ LANGUAGE plpgsql SECURITY DEFINER;

-- Mark lesson as completed
CREATE OR REPLACE FUNCTION public.complete_lesson(
    p_student_id UUID,
    p_lesson_id UUID
)
RETURNS JSON AS $$ DECLARE
    v_module_id UUID;
    v_course_id UUID;
    v_enrollment_id UUID;
BEGIN
    SELECT module_id INTO v_module_id FROM public.lessons WHERE id = p_lesson_id;
    SELECT course_id INTO v_course_id FROM public.modules WHERE id = v_module_id;

    INSERT INTO public.lesson_progress (student_id, lesson_id, completed, completed_at, watch_progress)
    VALUES (p_student_id, p_lesson_id, true, NOW(), 100)
    ON CONFLICT (student_id, lesson_id)
    DO UPDATE SET completed = true, completed_at = NOW(), watch_progress = 100;

    SELECT id INTO v_enrollment_id FROM public.enrollments
    WHERE student_id = p_student_id AND course_id = v_course_id;

    IF v_enrollment_id IS NOT NULL THEN
        PERFORM public.update_enrollment_progress(v_enrollment_id);
    END IF;

    RETURN json_build_object('success', true);
END;
 $$ LANGUAGE plpgsql SECURITY DEFINER;

-- Search courses
CREATE OR REPLACE FUNCTION public.search_courses(
    p_search_term TEXT DEFAULT '',
    p_category TEXT DEFAULT NULL,
    p_level course_level DEFAULT NULL,
    p_min_price DECIMAL DEFAULT NULL,
    p_max_price DECIMAL DEFAULT NULL,
    p_limit INTEGER DEFAULT 20,
    p_offset INTEGER DEFAULT 0
)
RETURNS JSON AS $$ DECLARE
    v_result JSON;
BEGIN
    SELECT json_agg(
        json_build_object(
            'id', c.id,
            'title', c.title,
            'short_description', c.short_description,
            'price', c.price,
            'currency', c.currency,
            'level', c.level,
            'category', c.category,
            'image', c.image,
            'provider_name', p.name,
            'provider_avatar', p.avatar,
            'enrollment_count', (SELECT COUNT(*) FROM public.enrollments WHERE course_id = c.id),
            'avg_rating', (SELECT COALESCE(AVG(rating), 0) FROM public.ratings WHERE course_id = c.id),
            'rating_count', (SELECT COUNT(*) FROM public.ratings WHERE course_id = c.id)
        )
    ) INTO v_result
    FROM public.courses c
    JOIN public.profiles p ON p.id = c.provider_id
    WHERE c.status = 'PUBLISHED'
    AND (p_search_term = '' OR c.title ILIKE '%' || p_search_term || '%' OR c.description ILIKE '%' || p_search_term || '%')
    AND (p_category IS NULL OR c.category = p_category)
    AND (p_level IS NULL OR c.level = p_level)
    AND (p_min_price IS NULL OR c.price >= p_min_price)
    AND (p_max_price IS NULL OR c.price <= p_max_price)
    ORDER BY c.created_at DESC
    LIMIT p_limit OFFSET p_offset;
    RETURN COALESCE(v_result, '[]'::JSON);
END;
 $$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- VIEWS FOR COMMON QUERIES
-- ============================================================

CREATE OR REPLACE VIEW public.course_details AS
SELECT
    c.*,
    p.name AS provider_name,
    p.avatar AS provider_avatar,
    p.institution_name,
    (SELECT COUNT(*) FROM public.enrollments WHERE course_id = c.id) AS enrollment_count,
    (SELECT COUNT(*) FROM public.modules WHERE course_id = c.id) AS module_count,
    (SELECT COUNT(*) FROM public.lessons l JOIN public.modules m ON m.id = l.module_id WHERE m.course_id = c.id) AS lesson_count,
    (SELECT COALESCE(AVG(r.rating), 0) FROM public.ratings r WHERE r.course_id = c.id) AS avg_rating,
    (SELECT COUNT(*) FROM public.ratings r WHERE r.course_id = c.id) AS rating_count,
    (SELECT COALESCE(SUM(l.duration), 0) FROM public.lessons l JOIN public.modules m ON m.id = l.module_id WHERE m.course_id = c.id) AS total_duration
FROM public.courses c
JOIN public.profiles p ON p.id = c.provider_id;

CREATE OR REPLACE VIEW public.enrollment_details AS
SELECT
    e.*,
    c.title AS course_title,
    c.image AS course_image,
    c.level AS course_level,
    c.price AS course_price,
    p.name AS provider_name,
    p.avatar AS provider_avatar,
    (SELECT COUNT(*) FROM public.certificates WHERE student_id = e.student_id AND course_id = e.course_id) AS has_certificate
FROM public.enrollments e
JOIN public.courses c ON c.id = e.course_id
JOIN public.profiles p ON p.id = c.provider_id;

-- ============================================================
-- REAL-TIME SUBSCRIPTIONS
-- ============================================================

ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
ALTER PUBLICATION supabase_realtime ADD TABLE public.enrollments;

-- ============================================================
-- END OF SCHEMA
-- ============================================================
-- ============================================================
-- WASLA PLATFORM - SECURITY UPDATES FOR AUTHENTICATION SYSTEM
-- Updated deployment-ready auth hardening script
-- ============================================================

CREATE TABLE IF NOT EXISTS public.login_attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT NOT NULL,
    ip_address TEXT,
    user_agent TEXT,
    success BOOLEAN DEFAULT FALSE,
    failure_reason TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_login_attempts_email_time
    ON public.login_attempts(email, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_login_attempts_success
    ON public.login_attempts(email, success, created_at);

CREATE TABLE IF NOT EXISTS public.user_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    device_name TEXT,
    device_type TEXT,
    device_id TEXT,
    ip_address TEXT,
    user_agent TEXT,
    last_activity TIMESTAMPTZ DEFAULT NOW(),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    ended_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_user_sessions_user
    ON public.user_sessions(user_id, is_active);
CREATE INDEX IF NOT EXISTS idx_user_sessions_device
    ON public.user_sessions(device_id, is_active);

CREATE TABLE IF NOT EXISTS public.security_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    event_type TEXT NOT NULL,
    event_description TEXT,
    ip_address TEXT,
    user_agent TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    severity TEXT DEFAULT 'INFO' CHECK (severity IN ('INFO', 'WARNING', 'ERROR', 'CRITICAL')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_security_logs_user
    ON public.security_logs(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_security_logs_type
    ON public.security_logs(event_type, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_security_logs_severity
    ON public.security_logs(severity, created_at DESC);

ALTER TABLE public.profiles
    ADD COLUMN IF NOT EXISTS two_factor_enabled BOOLEAN DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS two_factor_secret TEXT,
    ADD COLUMN IF NOT EXISTS two_factor_backup_codes TEXT[],
    ADD COLUMN IF NOT EXISTS two_factor_verified_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS last_login_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS last_login_ip TEXT,
    ADD COLUMN IF NOT EXISTS password_changed_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS failed_login_attempts INTEGER DEFAULT 0,
    ADD COLUMN IF NOT EXISTS account_locked_until TIMESTAMPTZ;

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    IF COALESCE(NEW.raw_user_meta_data->>'role', 'STUDENT') = 'ADMIN' THEN
        RAISE EXCEPTION 'Cannot create admin accounts through signup';
    END IF;

    INSERT INTO public.profiles (
        id,
        name,
        email,
        phone,
        gender,
        role,
        status,
        institution_type,
        institution_name,
        created_at,
        updated_at
    )
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'name', NEW.email),
        NEW.email,
        NULLIF(NEW.raw_user_meta_data->>'phone', ''),
        CASE
            WHEN COALESCE(NEW.raw_user_meta_data->>'gender', '') = 'أنثى' THEN 'FEMALE'::gender_type
            WHEN UPPER(COALESCE(NEW.raw_user_meta_data->>'gender', '')) = 'FEMALE' THEN 'FEMALE'::gender_type
            ELSE 'MALE'::gender_type
        END,
        COALESCE(NEW.raw_user_meta_data->>'role', 'STUDENT')::user_role,
        CASE
            WHEN COALESCE(NEW.raw_user_meta_data->>'role', 'STUDENT') = 'PROVIDER' THEN 'PENDING'::user_status
            WHEN NEW.email_confirmed_at IS NOT NULL THEN 'ACTIVE'::user_status
            ELSE 'PENDING'::user_status
        END,
        CASE
            WHEN NULLIF(NEW.raw_user_meta_data->>'institution_type', '') IS NULL THEN NULL
            ELSE (NEW.raw_user_meta_data->>'institution_type')::institution_type
        END,
        NULLIF(NEW.raw_user_meta_data->>'institution_name', ''),
        NOW(),
        NOW()
    )
    ON CONFLICT (id) DO UPDATE SET
        name = EXCLUDED.name,
        email = EXCLUDED.email,
        phone = COALESCE(EXCLUDED.phone, public.profiles.phone),
        institution_type = COALESCE(EXCLUDED.institution_type, public.profiles.institution_type),
        institution_name = COALESCE(EXCLUDED.institution_name, public.profiles.institution_name),
        updated_at = NOW();

    INSERT INTO public.security_logs (
        user_id,
        event_type,
        event_description,
        severity
    ) VALUES (
        NEW.id,
        'ACCOUNT_CREATED',
        'تم إنشاء حساب جديد',
        'INFO'
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.check_login_attempts(p_email TEXT)
RETURNS JSON AS $$
DECLARE
    v_failed_count INTEGER;
    v_last_attempt TIMESTAMPTZ;
    v_is_locked BOOLEAN;
    v_unlock_at TIMESTAMPTZ;
BEGIN
    SELECT COUNT(*), MAX(created_at)
    INTO v_failed_count, v_last_attempt
    FROM public.login_attempts
    WHERE email = LOWER(TRIM(p_email))
      AND success = FALSE
      AND created_at > NOW() - INTERVAL '1 hour';

    v_is_locked := v_failed_count >= 5;
    IF v_is_locked THEN
        v_unlock_at := v_last_attempt + INTERVAL '1 hour';
    END IF;

    RETURN json_build_object(
        'is_locked', v_is_locked,
        'failed_attempts', v_failed_count,
        'unlock_at', v_unlock_at,
        'remaining_attempts', GREATEST(0, 5 - v_failed_count)
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.log_login_attempt(
    p_email TEXT,
    p_success BOOLEAN,
    p_ip_address TEXT DEFAULT NULL,
    p_user_agent TEXT DEFAULT NULL,
    p_failure_reason TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    v_attempt_id UUID;
BEGIN
    INSERT INTO public.login_attempts (
        email,
        success,
        ip_address,
        user_agent,
        failure_reason
    ) VALUES (
        LOWER(TRIM(p_email)),
        p_success,
        p_ip_address,
        p_user_agent,
        p_failure_reason
    ) RETURNING id INTO v_attempt_id;

    IF p_success THEN
        UPDATE public.profiles
        SET
            last_login_at = NOW(),
            last_login_ip = p_ip_address,
            failed_login_attempts = 0,
            account_locked_until = NULL
        WHERE LOWER(email) = LOWER(TRIM(p_email));
    ELSE
        UPDATE public.profiles
        SET failed_login_attempts = COALESCE(failed_login_attempts, 0) + 1,
            account_locked_until = CASE
                WHEN COALESCE(failed_login_attempts, 0) + 1 >= 5 THEN NOW() + INTERVAL '1 hour'
                ELSE account_locked_until
            END
        WHERE LOWER(email) = LOWER(TRIM(p_email));
    END IF;

    RETURN v_attempt_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.create_user_session(
    p_user_id UUID,
    p_device_name TEXT DEFAULT NULL,
    p_device_type TEXT DEFAULT NULL,
    p_device_id TEXT DEFAULT NULL,
    p_ip_address TEXT DEFAULT NULL,
    p_user_agent TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    v_session_id UUID;
BEGIN
    IF p_device_id IS NOT NULL THEN
        UPDATE public.user_sessions
        SET is_active = FALSE,
            ended_at = NOW()
        WHERE user_id = p_user_id
          AND device_id = p_device_id
          AND is_active = TRUE;
    END IF;

    INSERT INTO public.user_sessions (
        user_id,
        device_name,
        device_type,
        device_id,
        ip_address,
        user_agent,
        is_active
    ) VALUES (
        p_user_id,
        p_device_name,
        p_device_type,
        p_device_id,
        p_ip_address,
        p_user_agent,
        TRUE
    ) RETURNING id INTO v_session_id;

    INSERT INTO public.security_logs (
        user_id,
        event_type,
        event_description,
        ip_address,
        user_agent,
        metadata
    ) VALUES (
        p_user_id,
        'LOGIN_SUCCESS',
        'تسجيل دخول ناجح',
        p_ip_address,
        p_user_agent,
        json_build_object(
            'device_name', p_device_name,
            'device_type', p_device_type,
            'device_id', p_device_id
        )
    );

    RETURN v_session_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.end_user_session(
    p_session_id UUID DEFAULT NULL,
    p_user_id UUID DEFAULT NULL,
    p_end_all BOOLEAN DEFAULT FALSE
)
RETURNS INTEGER AS $$
DECLARE
    v_affected_rows INTEGER;
BEGIN
    IF p_end_all AND p_user_id IS NOT NULL THEN
        UPDATE public.user_sessions
        SET is_active = FALSE,
            ended_at = NOW()
        WHERE user_id = p_user_id
          AND is_active = TRUE;

        GET DIAGNOSTICS v_affected_rows = ROW_COUNT;

        INSERT INTO public.security_logs (
            user_id,
            event_type,
            event_description,
            severity
        ) VALUES (
            p_user_id,
            'LOGOUT_ALL_DEVICES',
            'تسجيل خروج من جميع الأجهزة',
            'WARNING'
        );
    ELSIF p_session_id IS NOT NULL THEN
        UPDATE public.user_sessions
        SET is_active = FALSE,
            ended_at = NOW()
        WHERE id = p_session_id
          AND is_active = TRUE;

        GET DIAGNOSTICS v_affected_rows = ROW_COUNT;
    ELSE
        v_affected_rows := 0;
    END IF;

    RETURN v_affected_rows;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.log_security_event(
    p_user_id UUID,
    p_event_type TEXT,
    p_event_description TEXT,
    p_ip_address TEXT DEFAULT NULL,
    p_user_agent TEXT DEFAULT NULL,
    p_metadata JSONB DEFAULT '{}'::jsonb,
    p_severity TEXT DEFAULT 'INFO'
)
RETURNS UUID AS $$
DECLARE
    v_log_id UUID;
BEGIN
    INSERT INTO public.security_logs (
        user_id,
        event_type,
        event_description,
        ip_address,
        user_agent,
        metadata,
        severity
    ) VALUES (
        p_user_id,
        p_event_type,
        p_event_description,
        p_ip_address,
        p_user_agent,
        COALESCE(p_metadata, '{}'::jsonb),
        p_severity
    ) RETURNING id INTO v_log_id;

    RETURN v_log_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.cleanup_old_logs()
RETURNS INTEGER AS $$
DECLARE
    v_deleted_count INTEGER := 0;
    v_temp_count INTEGER;
BEGIN
    DELETE FROM public.login_attempts
    WHERE created_at < NOW() - INTERVAL '90 days';
    GET DIAGNOSTICS v_temp_count = ROW_COUNT;
    v_deleted_count := v_deleted_count + v_temp_count;

    DELETE FROM public.user_sessions
    WHERE is_active = FALSE
      AND ended_at < NOW() - INTERVAL '90 days';
    GET DIAGNOSTICS v_temp_count = ROW_COUNT;
    v_deleted_count := v_deleted_count + v_temp_count;

    DELETE FROM public.security_logs
    WHERE created_at < NOW() - INTERVAL '180 days'
      AND severity != 'CRITICAL';
    GET DIAGNOSTICS v_temp_count = ROW_COUNT;
    v_deleted_count := v_deleted_count + v_temp_count;

    RETURN v_deleted_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

ALTER TABLE public.login_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.security_logs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins can view login attempts" ON public.login_attempts;
CREATE POLICY "Admins can view login attempts" ON public.login_attempts
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'ADMIN')
    );

DROP POLICY IF EXISTS "Users can view own sessions" ON public.user_sessions;
CREATE POLICY "Users can view own sessions" ON public.user_sessions
    FOR SELECT USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Users can end own sessions" ON public.user_sessions;
CREATE POLICY "Users can end own sessions" ON public.user_sessions
    FOR UPDATE USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Admins can view all sessions" ON public.user_sessions;
CREATE POLICY "Admins can view all sessions" ON public.user_sessions
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'ADMIN')
    );

DROP POLICY IF EXISTS "Users can view own security logs" ON public.security_logs;
CREATE POLICY "Users can view own security logs" ON public.security_logs
    FOR SELECT USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Admins can view all security logs" ON public.security_logs;
CREATE POLICY "Admins can view all security logs" ON public.security_logs
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'ADMIN')
    );

DROP POLICY IF EXISTS "Users can insert their own profile" ON public.profiles;
CREATE POLICY "Users can insert their own profile" ON public.profiles
    FOR INSERT WITH CHECK (
        id = auth.uid() AND role IN ('STUDENT', 'PROVIDER')
    );

CREATE TABLE IF NOT EXISTS public.password_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    password_hash TEXT NOT NULL,
    changed_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_password_history_user
    ON public.password_history(user_id, changed_at DESC);

ALTER TABLE public.password_history ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own password history" ON public.password_history;
CREATE POLICY "Users can view own password history" ON public.password_history
    FOR SELECT USING (user_id = auth.uid());

CREATE OR REPLACE VIEW public.recent_failed_logins AS
SELECT
    la.email,
    la.ip_address,
    la.failure_reason,
    la.created_at,
    p.name,
    p.role,
    p.status
FROM public.login_attempts la
LEFT JOIN public.profiles p ON LOWER(p.email) = LOWER(la.email)
WHERE la.success = FALSE
  AND la.created_at > NOW() - INTERVAL '7 days'
ORDER BY la.created_at DESC;

CREATE OR REPLACE VIEW public.active_sessions_summary AS
SELECT
    us.user_id,
    p.name,
    p.email,
    p.role,
    COUNT(*) as active_sessions_count,
    MAX(us.last_activity) as last_activity,
    array_agg(us.device_name) as devices
FROM public.user_sessions us
JOIN public.profiles p ON p.id = us.user_id
WHERE us.is_active = TRUE
GROUP BY us.user_id, p.name, p.email, p.role;

CREATE OR REPLACE VIEW public.critical_security_events AS
SELECT
    sl.user_id,
    p.name,
    p.email,
    p.role,
    sl.event_type,
    sl.event_description,
    sl.ip_address,
    sl.created_at
FROM public.security_logs sl
LEFT JOIN public.profiles p ON p.id = sl.user_id
WHERE sl.severity IN ('ERROR', 'CRITICAL')
  AND sl.created_at > NOW() - INTERVAL '30 days'
ORDER BY sl.created_at DESC;

INSERT INTO public.system_settings (key, value, description) VALUES
('security_event_types',
 '["ACCOUNT_CREATED","LOGIN_SUCCESS","LOGIN_FAILED","LOGOUT","LOGOUT_ALL_DEVICES","PASSWORD_CHANGED","PASSWORD_RESET_REQUESTED","PASSWORD_RESET_COMPLETED","PROFILE_UPDATED","2FA_ENABLED","2FA_DISABLED","2FA_VERIFIED","SUSPICIOUS_ACTIVITY","ACCOUNT_LOCKED","ACCOUNT_UNLOCKED"]',
 'أنواع الأحداث الأمنية المدعومة')
ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;
