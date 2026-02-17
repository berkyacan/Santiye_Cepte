-- =====================================================
-- ŞANTİYE CEPTE - YENİ İŞ AKIŞI GÜNCELLEMESİ
-- Bu script'i Supabase SQL Editor'de çalıştırın
-- =====================================================

-- 1. Mevcut politikayı kaldır
DROP POLICY IF EXISTS "Müteahhitler iş ilanı oluşturabilir" ON jobs;

-- 2. Yeni politika: Müteahhitler VE Taşeronlar iş ilanı oluşturabilir
CREATE POLICY "Müteahhit ve Taşeronlar iş ilanı oluşturabilir" ON jobs
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM profiles 
            WHERE id = auth.uid() 
            AND (role = 'contractor' OR role = 'subcontractor')
        )
    );

-- 3. Usta'ların da teklif/başvuru yapabilmesi için bids tablosuna usta desteği ekle
DROP POLICY IF EXISTS "Aktif abonelikli taşeronlar teklif verebilir" ON bids;

CREATE POLICY "Taşeronlar ve Ustalar teklif/başvuru yapabilir" ON bids
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM profiles 
            WHERE id = auth.uid() 
            AND (role = 'subcontractor' OR role = 'worker')
        )
    );

-- NOT: 
-- - Müteahhit iş ilanı yayınlar -> Taşeronlar teklif verir (pazarlık sistemi)
-- - Taşeron usta arama ilanı yayınlar -> Ustalar kabul/ret yapar (yevmiye sistemi)
-- 
-- Yevmiye değeri budget_min ve budget_max alanlarına aynı değer olarak kaydedilir.
