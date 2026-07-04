# Pati — Yazılımcı Uygulama Handoff

## Bağlayıcı kaynaklar

1. `pati-api/TEKNOLOJI-YIGINI.md` — teknoloji seçimi
2. `pati-api/SERVIS-SINIRLARI.md` — modül sahipliği ve yasak bağımlılıklar
3. `pati-api/openapi.yaml` — HTTP sözleşmesinin tek doğruluk kaynağı
4. `pati-sql/migrations/*.sql` — veritabanı şemasının tek doğruluk kaynağı
5. `PATI-MIMARI.md` ve `pati/*.puml` — iş akışı, güvenlik ve operasyon kararları
6. `pati-load-test/` — Postman/Newman 1K/5K/10K yük testi

## Uygulama sırası

### Faz 0 — Repo ve platform

- Monorepo: `apps/mobile`, `apps/web`, `apps/api`, `apps/worker`, `apps/ai-gateway`, `packages/contracts`, `packages/design-system`.
- PostgreSQL, Redis, NATS, Temporal ve S3 yerel compose ortamı.
- OpenAPI'den TypeScript istemci ve DTO üretimi.
- Migration runner, seed, test database ve CI lint/test.
- OpenTelemetry, structured logging, request ID ve RFC 9457 hata katmanı.

### Faz 1 — Kimlik, pet ve keşif

- Auth/register/login/refresh rotation.
- Kullanıcı, adres, pet, caregiver ve sağlık kaydı.
- Sağlayıcı onboarding, kategori, hizmet ve geo keşif.
- RBAC/ABAC, kaynak sahipliği ve audit.

### Faz 2 — Rezervasyon çekirdeği

- Uygunluk, kaynak kapasitesi ve çakışma constraint'i.
- Quote, fiyat/politika sürümü ve idempotent reservation.
- Sağlayıcı kabul/ret, başlatma, tamamlama ve iptal state machine.
- Transactional outbox ve Temporal timeout workflow'ları.

### Faz 3 — Finans ve güven

- Payment intent, imzalı webhook, append-only ledger.
- İade, payout, mutabakat ve finans audit'i.
- Doğrulanmış yorum, uyuşmazlık ve kanıt.

### Faz 4 — CRM, AI ve 3D

- İzin, opt-out, bildirim ve kanal politikası.
- AI Gateway, sağlık RAG ve insan incelemesi.
- Signed upload, 3D job, reconstruction pipeline ve viewer.

## Definition of Done

- Endpoint OpenAPI sözleşmesine karşı contract testinden geçer.
- Yetkisiz kaynak erişimi için negatif test bulunur.
- Yazma endpoint'i idempotency tekrar testinden geçer.
- Domain değişikliği aynı transaction'da outbox üretir.
- Migration temiz PostgreSQL'de ve önceki sürümden upgrade senaryosunda geçer.
- Log, trace ve metric; PII/token/sağlık ham verisi içermez.
- Kritik akışlarda unit + integration + e2e + failure-path testleri bulunur.
- Erişilebilirlik, rate limit, timeout ve rollback doğrulanır.

## İlk sprintte yapılmayacaklar

- Booking ve Payment'ı ayrı mikroservise bölmek
- Özel Kubernetes operator yazmak
- Genel pet görsellerini izinsiz model eğitiminde kullanmak
- OpenSearch'i PostgreSQL araması ölçülmeden devreye almak
- AI sonucuyla otomatik tıbbi, finansal veya yaptırım kararı vermek
