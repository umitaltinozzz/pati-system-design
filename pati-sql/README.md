# Pati PostgreSQL Şeması

Hedef: PostgreSQL 16. Şema Supabase'e bağımlı değildir.

## Migration sırası

1. `migrations/001_foundation.sql` — extension, şema, ortak fonksiyon ve lookup tabloları
2. `migrations/002_identity_pets.sql` — kullanıcı, rol, adres, pet ve sağlık kayıtları
3. `migrations/003_providers_catalog.sql` — işletme, belge, hizmet, kaynak ve takvim
4. `migrations/004_booking_finance.sql` — teklif, rezervasyon, ödeme, ledger, payout ve uyuşmazlık
5. `migrations/005_comms_ai_3d.sql` — izin, iletişim, bildirim, AI ve 3D varlıklar
6. `migrations/006_platform.sql` — idempotency, outbox, audit, indeks ve koruma trigger'ları

Migration'lar ileri yönlüdür. Üretimde geri dönüş, veri kaybettiren `down` scriptleriyle değil önceki uygulama sürümüne uyumlu forward-fix migration ile yapılır.

## Temel kararlar

- İç PK: `bigint generated always as identity`
- API kimliği: `public_id uuid default gen_random_uuid()`
- Para: `numeric(14,2)` + üç harfli para birimi
- Zaman: yalnız `timestamptz`; uygulama/DB UTC
- Soft delete yalnız kullanıcı içeriğinde; finans/audit kayıtları append-only
- Hassas alanlar uygulama/KMS katmanında şifrelenmiş `bytea`
- FK sütunlarının tamamı indekslenir
- Rezervasyon ve ödeme tarafında `idempotency_key` ve outbox zorunludur

