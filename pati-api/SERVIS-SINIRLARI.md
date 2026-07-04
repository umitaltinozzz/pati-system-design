# Pati — Kesin Servis ve Modül Sınırları

## Dağıtım kararı

İlk sürümde tek API deployment içinde modüler monolit kullanılır. Her modül yalnız kendi application service ve repository arayüzü üzerinden çağrılır. Modüller başka modülün tablosuna doğrudan SQL yazamaz. AI/3D, bildirim worker'ları ve yoğun import işleri ayrı process/deployment'tır.

## Modüller

| Modül | Sahip olduğu tablolar | Senkron API | Yayınladığı olaylar |
|---|---|---|---|
| Identity | `app_user`, `user_role`, `address` | kayıt, oturum, profil, rol | `UserRegistered`, `UserDeletionRequested` |
| Pet | `pet`, `pet_caregiver`, `pet_health_record` | pet CRUD, paylaşım, sağlık kaydı | `PetCreated`, `HealthRecordAdded` |
| Provider | `business`, `business_member`, `provider_document` | onboarding, belge, doğrulama | `ProviderSubmitted`, `ProviderVerified` |
| Catalog | `service_category`, `service`, `provider_resource` | kategori, hizmet, kaynak | `ServicePublished` |
| Availability | `availability_rule`, `availability_exception`, `reservation_resource` | uygunluk, hold/release | `CapacityHeld`, `CapacityReleased` |
| Booking | `quote`, `reservation`, `reservation_status_history` | teklif, rezervasyon state machine | `ReservationCreated/Accepted/Completed` |
| Payment | `payment`, `ledger_entry`, `payout_account`, `payout` | payment intent, refund, payout | `PaymentAuthorized`, `RefundCompleted`, `PayoutPaid` |
| Trust | `review`, `dispute`, `dispute_evidence` | yorum, şikâyet, uyuşmazlık | `ReviewPublished`, `DisputeOpened/Resolved` |
| Consent/CRM | `consent_record`, `communication_log`, `notification` | izin, opt-out, bildirim | `ConsentWithdrawn`, `NotificationRequested` |
| AI/3D | `ai_job`, `ai_health_assessment`, `pet_3d_asset` | job oluştur/durum/sonuç | `AiJobQueued/Completed`, `AvatarApproved` |
| Platform | `idempotency_record`, `outbox_event`, `audit_event` | iç altyapı | tüm olayların güvenli dağıtımı |

## Yasak bağımlılıklar

- Payment, Booking tablosunu doğrudan güncellemez; ödeme sonucunu olay/API ile bildirir.
- Notification hiçbir domain kararını vermez; yalnız şablon/politika sonucu teslimat yapar.
- AI çıktısı Booking, Payment veya yaptırım durumunu tek başına değiştiremez.
- Admin endpoint'i repository'leri atlayamaz; aynı domain command'larını gerekçe ve audit ile çağırır.
- Mobil/web istemci obje deposuna kalıcı açık URL ile erişemez; kısa ömürlü signed URL kullanır.

## Transaction sınırları

- Tek modül içindeki değişiklik + outbox aynı PostgreSQL transaction'ında yazılır.
- Harici ödeme/WhatsApp/AI çağrısı açık DB transaction içinde yapılmaz.
- Modüller arası uzun işlem Temporal workflow ve telafi adımlarıyla yürür.
- Aynı endpoint tekrarında `Idempotency-Key` aynı cevap veya `409 IDEMPOTENCY_KEY_REUSED` üretir.

## Ayrıştırma kapıları

Bir modül ancak şu koşullardan biri gerçekleşirse ayrı servise çıkarılır:

1. Bağımsız ölçek gereksinimi API kümesinden 5× fazla olur.
2. Ayrı güvenlik/uyum sınırı gerekir.
3. Deployment sıklığı veya hata alanı ana API'yi ölçülebilir biçimde etkiler.
4. Modül sahipliği ayrı ekip ve SLO ile yürütülür.

İlk ayrılma adayları AI/3D, Notification ve Import'tur; Booking ile Payment erken ayrılmaz.

