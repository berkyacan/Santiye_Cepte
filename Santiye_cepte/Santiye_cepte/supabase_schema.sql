-- =====================================================
-- ŞANTIYE CEPTE - SUPABASE VERİTABANI ŞEMASI
-- İnşaat Pazaryeri Uygulaması
-- =====================================================

-- Uzantıları etkinleştir
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- ENUM TİPLERİ
-- =====================================================

-- Kullanıcı rolleri
CREATE TYPE user_role AS ENUM ('contractor', 'subcontractor', 'worker');

-- İş durumları
CREATE TYPE job_status AS ENUM ('active', 'in_progress', 'completed', 'cancelled');

-- Teklif durumları
CREATE TYPE bid_status AS ENUM ('pending', 'accepted', 'rejected', 'withdrawn');

-- Abonelik durumları
CREATE TYPE subscription_status AS ENUM ('trial', 'active', 'expired', 'cancelled');

-- Meslek/Uzmanlık alanları
CREATE TYPE trade_type AS ENUM (
    'soguk_demir',      -- Soğuk Demir
    'kalipci',          -- Kalıpçı
    'duvarci',          -- Duvarcı
    'sivaci',           -- Sıvacı
    'elektrikci',       -- Elektrikçi
    'tesisatci',        -- Tesisatçı
    'boyaci',           -- Boyacı
    'seramikci',        -- Seramikçi
    'marangoz',         -- Marangoz
    'kaynak',           -- Kaynakçı
    'izolasyon',        -- İzolasyoncu
    'alcipan',          -- Alçıpancı
    'betoncu',          -- Betoncu
    'hafriyat',         -- Hafriyatçı
    'diger'             -- Diğer
);

-- =====================================================
-- TABLOLAR
-- =====================================================

-- 1. KULLANICI PROFİLLERİ
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    full_name TEXT NOT NULL,
    phone TEXT,
    role user_role NOT NULL,
    avatar_url TEXT,
    
    -- Konum bilgileri (Antalya odaklı)
    city TEXT DEFAULT 'Antalya',
    district TEXT,
    address TEXT,
    
    -- İşçi/Taşeron için ek bilgiler
    trade_types trade_type[] DEFAULT '{}',
    experience_years INTEGER DEFAULT 0,
    bio TEXT,
    rating DECIMAL(2,1) DEFAULT 0.0,
    total_reviews INTEGER DEFAULT 0,
    
    -- Müteahhit için ek bilgiler
    company_name TEXT,
    tax_number TEXT,
    
    -- Durum
    is_active BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false,
    
    -- Zaman damgaları
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. ABONELİKLER (Taşeronlar için)
CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    
    status subscription_status NOT NULL DEFAULT 'trial',
    
    -- Deneme süresi
    trial_started_at TIMESTAMPTZ,
    trial_ends_at TIMESTAMPTZ,
    
    -- Aktif abonelik
    subscription_started_at TIMESTAMPTZ,
    subscription_ends_at TIMESTAMPTZ,
    
    -- Ödeme bilgileri
    monthly_price DECIMAL(10,2) DEFAULT 1000.00,
    last_payment_at TIMESTAMPTZ,
    next_payment_at TIMESTAMPTZ,
    
    -- Zaman damgaları
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(user_id)
);

-- 3. İŞ İLANLARI
CREATE TABLE jobs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    contractor_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    
    -- İlan detayları
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    trade_type trade_type NOT NULL,
    
    -- Konum
    city TEXT DEFAULT 'Antalya',
    district TEXT,
    address TEXT,
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    
    -- Süre ve bütçe
    duration_days INTEGER,
    start_date DATE,
    end_date DATE,
    budget_min DECIMAL(12,2),
    budget_max DECIMAL(12,2),
    
    -- Çalışan ihtiyacı
    workers_needed INTEGER DEFAULT 1,
    
    -- Durum
    status job_status DEFAULT 'active',
    views_count INTEGER DEFAULT 0,
    bids_count INTEGER DEFAULT 0,
    
    -- Zaman damgaları
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. TEKLİFLER
CREATE TABLE bids (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    job_id UUID NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
    subcontractor_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    
    -- Teklif detayları
    amount DECIMAL(12,2) NOT NULL,
    message TEXT,
    proposed_duration_days INTEGER,
    proposed_start_date DATE,
    
    -- Durum
    status bid_status DEFAULT 'pending',
    
    -- Zaman damgaları
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Aynı işe birden fazla teklif vermeyi engelle
    UNIQUE(job_id, subcontractor_id)
);

-- 5. İŞÇİ PAZARYERİ (Taşeronların işçi araması için)
CREATE TABLE worker_listings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    worker_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    
    -- Listeleme detayları
    title TEXT NOT NULL,
    description TEXT,
    trade_types trade_type[] NOT NULL,
    
    -- Ücret bilgisi
    daily_rate DECIMAL(10,2),
    hourly_rate DECIMAL(10,2),
    
    -- Müsaitlik
    is_available BOOLEAN DEFAULT true,
    available_from DATE,
    
    -- Konum tercihi
    preferred_districts TEXT[],
    
    -- Zaman damgaları
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(worker_id)
);

-- 6. DEĞERLENDİRMELER/YORUMLAR
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reviewer_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    reviewed_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    job_id UUID REFERENCES jobs(id) ON DELETE SET NULL,
    
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Aynı kişiyi aynı iş için birden fazla değerlendirmeyi engelle
    UNIQUE(reviewer_id, reviewed_id, job_id)
);

-- 7. BİLDİRİMLER
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    type TEXT NOT NULL, -- 'bid', 'job', 'subscription', 'system'
    
    -- İlgili kayıt
    related_id UUID,
    related_type TEXT,
    
    is_read BOOLEAN DEFAULT false,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- İNDEKSLER
-- =====================================================

CREATE INDEX idx_profiles_role ON profiles(role);
CREATE INDEX idx_profiles_city ON profiles(city);
CREATE INDEX idx_profiles_trade_types ON profiles USING GIN(trade_types);

CREATE INDEX idx_subscriptions_user_id ON subscriptions(user_id);
CREATE INDEX idx_subscriptions_status ON subscriptions(status);
CREATE INDEX idx_subscriptions_trial_ends_at ON subscriptions(trial_ends_at);

CREATE INDEX idx_jobs_contractor_id ON jobs(contractor_id);
CREATE INDEX idx_jobs_status ON jobs(status);
CREATE INDEX idx_jobs_trade_type ON jobs(trade_type);
CREATE INDEX idx_jobs_city ON jobs(city);
CREATE INDEX idx_jobs_created_at ON jobs(created_at DESC);

CREATE INDEX idx_bids_job_id ON bids(job_id);
CREATE INDEX idx_bids_subcontractor_id ON bids(subcontractor_id);
CREATE INDEX idx_bids_status ON bids(status);

CREATE INDEX idx_worker_listings_worker_id ON worker_listings(worker_id);
CREATE INDEX idx_worker_listings_trade_types ON worker_listings USING GIN(trade_types);

CREATE INDEX idx_reviews_reviewed_id ON reviews(reviewed_id);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);

-- =====================================================
-- FONKSİYONLAR
-- =====================================================

-- Profil güncelleme zamanını otomatik güncelle
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Yeni kullanıcı kaydında profil ve abonelik oluştur
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    -- Profil oluştur
    INSERT INTO profiles (id, email, full_name, role)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', 'Kullanıcı'),
        COALESCE((NEW.raw_user_meta_data->>'role')::user_role, 'worker')
    );
    
    -- Taşeron ise 30 günlük deneme aboneliği oluştur
    IF (NEW.raw_user_meta_data->>'role') = 'subcontractor' THEN
        INSERT INTO subscriptions (user_id, status, trial_started_at, trial_ends_at)
        VALUES (
            NEW.id,
            'trial',
            NOW(),
            NOW() + INTERVAL '30 days'
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Abonelik durumunu kontrol et
CREATE OR REPLACE FUNCTION check_subscription_status(p_user_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    v_subscription subscriptions%ROWTYPE;
BEGIN
    SELECT * INTO v_subscription FROM subscriptions WHERE user_id = p_user_id;
    
    IF NOT FOUND THEN
        RETURN FALSE;
    END IF;
    
    -- Deneme süresi aktif mi?
    IF v_subscription.status = 'trial' AND v_subscription.trial_ends_at > NOW() THEN
        RETURN TRUE;
    END IF;
    
    -- Aktif abonelik var mı?
    IF v_subscription.status = 'active' AND v_subscription.subscription_ends_at > NOW() THEN
        RETURN TRUE;
    END IF;
    
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- İş ilanı görüntülenme sayısını artır
CREATE OR REPLACE FUNCTION increment_job_views(p_job_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE jobs SET views_count = views_count + 1 WHERE id = p_job_id;
END;
$$ LANGUAGE plpgsql;

-- Değerlendirme sonrası rating güncelle
CREATE OR REPLACE FUNCTION update_user_rating()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE profiles
    SET 
        rating = (
            SELECT ROUND(AVG(rating)::numeric, 1)
            FROM reviews
            WHERE reviewed_id = NEW.reviewed_id
        ),
        total_reviews = (
            SELECT COUNT(*)
            FROM reviews
            WHERE reviewed_id = NEW.reviewed_id
        )
    WHERE id = NEW.reviewed_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- TRİGGERLAR
-- =====================================================

-- updated_at otomatik güncelleme
CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_subscriptions_updated_at
    BEFORE UPDATE ON subscriptions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_jobs_updated_at
    BEFORE UPDATE ON jobs
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_bids_updated_at
    BEFORE UPDATE ON bids
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_worker_listings_updated_at
    BEFORE UPDATE ON worker_listings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Yeni kullanıcı trigger'ı
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- Değerlendirme sonrası rating güncelleme
CREATE TRIGGER update_rating_after_review
    AFTER INSERT ON reviews
    FOR EACH ROW EXECUTE FUNCTION update_user_rating();

-- =====================================================
-- ROW LEVEL SECURITY (RLS) POLİTİKALARI
-- =====================================================

-- Tüm tablolarda RLS'i etkinleştir
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE bids ENABLE ROW LEVEL SECURITY;
ALTER TABLE worker_listings ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Profiles politikaları
CREATE POLICY "Profiller herkese açık okuma" ON profiles
    FOR SELECT USING (true);

CREATE POLICY "Kullanıcılar kendi profilini düzenleyebilir" ON profiles
    FOR UPDATE USING (auth.uid() = id);

-- Subscriptions politikaları
CREATE POLICY "Kullanıcılar kendi aboneliğini görebilir" ON subscriptions
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Kullanıcılar kendi aboneliğini güncelleyebilir" ON subscriptions
    FOR UPDATE USING (auth.uid() = user_id);

-- Jobs politikaları
CREATE POLICY "Aktif işler herkese açık" ON jobs
    FOR SELECT USING (status = 'active' OR contractor_id = auth.uid());

CREATE POLICY "Müteahhitler iş ilanı oluşturabilir" ON jobs
    FOR INSERT WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'contractor')
    );

CREATE POLICY "Müteahhitler kendi ilanlarını düzenleyebilir" ON jobs
    FOR UPDATE USING (contractor_id = auth.uid());

CREATE POLICY "Müteahhitler kendi ilanlarını silebilir" ON jobs
    FOR DELETE USING (contractor_id = auth.uid());

-- Bids politikaları
CREATE POLICY "Teklif veren ve iş sahibi teklifleri görebilir" ON bids
    FOR SELECT USING (
        subcontractor_id = auth.uid() OR
        EXISTS (SELECT 1 FROM jobs WHERE jobs.id = bids.job_id AND jobs.contractor_id = auth.uid())
    );

CREATE POLICY "Aktif abonelikli taşeronlar teklif verebilir" ON bids
    FOR INSERT WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'subcontractor') AND
        check_subscription_status(auth.uid())
    );

CREATE POLICY "Taşeronlar kendi tekliflerini düzenleyebilir" ON bids
    FOR UPDATE USING (subcontractor_id = auth.uid());

-- Worker listings politikaları
CREATE POLICY "İşçi listeleri aktif abonelikli kullanıcılara açık" ON worker_listings
    FOR SELECT USING (
        -- İşçi kendi listesini görebilir
        worker_id = auth.uid() OR
        -- Aktif abonelikli taşeronlar görebilir
        (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'subcontractor') AND
         check_subscription_status(auth.uid()))
    );

CREATE POLICY "İşçiler kendi listesini oluşturabilir" ON worker_listings
    FOR INSERT WITH CHECK (
        EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'worker') AND
        worker_id = auth.uid()
    );

CREATE POLICY "İşçiler kendi listesini düzenleyebilir" ON worker_listings
    FOR UPDATE USING (worker_id = auth.uid());

-- Reviews politikaları
CREATE POLICY "Değerlendirmeler herkese açık" ON reviews
    FOR SELECT USING (true);

CREATE POLICY "Giriş yapmış kullanıcılar değerlendirme yapabilir" ON reviews
    FOR INSERT WITH CHECK (auth.uid() = reviewer_id);

-- Notifications politikaları
CREATE POLICY "Kullanıcılar kendi bildirimlerini görebilir" ON notifications
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Kullanıcılar kendi bildirimlerini güncelleyebilir" ON notifications
    FOR UPDATE USING (user_id = auth.uid());

-- =====================================================
-- ÖRNEK VERİLER (Test için)
-- =====================================================

-- Not: Bu veriler auth.users tablosunda kullanıcılar oluşturulduktan sonra eklenecektir.
-- Şimdilik sadece trade_type için Türkçe eşleştirme tablosu oluşturalım

CREATE TABLE trade_type_translations (
    trade_type trade_type PRIMARY KEY,
    turkish_name TEXT NOT NULL,
    icon_name TEXT
);

INSERT INTO trade_type_translations (trade_type, turkish_name, icon_name) VALUES
    ('soguk_demir', 'Soğuk Demir', 'construction'),
    ('kalipci', 'Kalıpçı', 'view_in_ar'),
    ('duvarci', 'Duvarcı', 'fence'),
    ('sivaci', 'Sıvacı', 'format_paint'),
    ('elektrikci', 'Elektrikçi', 'electrical_services'),
    ('tesisatci', 'Tesisatçı', 'plumbing'),
    ('boyaci', 'Boyacı', 'brush'),
    ('seramikci', 'Seramikçi', 'grid_view'),
    ('marangoz', 'Marangoz', 'carpenter'),
    ('kaynak', 'Kaynakçı', 'local_fire_department'),
    ('izolasyon', 'İzolasyoncu', 'layers'),
    ('alcipan', 'Alçıpancı', 'dashboard'),
    ('betoncu', 'Betoncu', 'foundation'),
    ('hafriyat', 'Hafriyatçı', 'landscape'),
    ('diger', 'Diğer', 'handyman');

-- =====================================================
-- GÖRÜNÜMLER (Views)
-- =====================================================

-- Aktif iş ilanları görünümü
CREATE VIEW active_jobs_view AS
SELECT 
    j.*,
    p.full_name AS contractor_name,
    p.company_name,
    p.phone AS contractor_phone,
    p.rating AS contractor_rating,
    t.turkish_name AS trade_type_name
FROM jobs j
JOIN profiles p ON j.contractor_id = p.id
JOIN trade_type_translations t ON j.trade_type = t.trade_type
WHERE j.status = 'active'
ORDER BY j.created_at DESC;

-- Kullanıcı abonelik durumu görünümü
CREATE VIEW user_subscription_view AS
SELECT 
    s.*,
    p.full_name,
    p.email,
    CASE 
        WHEN s.status = 'trial' THEN s.trial_ends_at - NOW()
        WHEN s.status = 'active' THEN s.subscription_ends_at - NOW()
        ELSE INTERVAL '0 days'
    END AS remaining_time,
    CASE 
        WHEN s.status = 'trial' THEN EXTRACT(DAY FROM (s.trial_ends_at - NOW()))
        WHEN s.status = 'active' THEN EXTRACT(DAY FROM (s.subscription_ends_at - NOW()))
        ELSE 0
    END AS remaining_days
FROM subscriptions s
JOIN profiles p ON s.user_id = p.id;
