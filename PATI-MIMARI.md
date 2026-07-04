# Pati Platformu — UML ve Mimari Özeti

## Kapsam

Bu belge `pati.md` gereksinimlerini uygulanabilir hedef mimariye dönüştürür. Pati; pet sahipleri ile doğrulanmış veteriner, kuaför, walker, hotel, eğitmen ve taksi gibi hizmet sağlayıcıları buluşturan, rezervasyon ve korumalı ödeme odaklı iki taraflı pazaryeridir.

## Aktörler ve ana değer akışı

- **Pet sahibi:** pet profili ve sağlık kaydı yönetir; hizmet arar, rezervasyon ve ödeme yapar, onay ve yorum verir.
- **Hizmet sağlayıcı:** işletme/hizmet/takvim yönetir; talepleri kabul eder, hizmeti tamamlar ve hak ediş izler.
- **Operasyon:** veri toplama, VoIP doğrulama ve izinli WhatsApp iletişimini yönetir.
- **Admin/Super admin:** doğrulama, uyuşmazlık, ödeme, kategori, kullanıcı, içerik ve denetim süreçlerini yönetir.

## Mimari kararlar

1. Kullanıcı, işletme ve admin arayüzleri aynı API platformuna bağlanan ayrı deneyimlerdir.
2. Rezervasyon, ödeme ve hak ediş tek bir orkestre iş akışı olarak ele alınır.
3. Sağlık kayıtları ve AI sağlık asistanı hassas veri sınırında tutulur; asistan veteriner yerine geçmez.
4. WhatsApp iletişimi açık izin kaydıyla, VoIP doğrulaması denetlenebilir çağrı loglarıyla çalışır.
5. Admin işlemleri ve ödeme durum değişiklikleri değiştirilemez denetim izine yazılır.

## Kritik durum makineleri

- Rezervasyon: `oluşturuldu → sağlayıcı onayı → hizmet başladı → çift taraflı onay → tamamlandı/uyuşmazlık`
- Ödeme: `bekliyor → başarılı → blokede → hak ediş/iade/uyuşmazlık`
- İşletme: `aday → arandı → onay bekliyor → doğrulandı → aktif/pasif/askıda`

## Diyagram seti

Dokuz karşılaştırmalı diyagrama ek olarak üretim kararlarını kapsayan elli bir derin analiz diyagramı vardır. PlantUML kaynakları ve SVG çıktıları `pati/` klasöründedir.

## Üretim kalitesi için tamamlanan kritik alanlar

### Veri ve sınırlar

- Kullanıcı, pet, hassas sağlık kaydı, işletme, hizmet, slot, rezervasyon, ödeme, ledger, yorum, uyuşmazlık ve izin kayıtlarının ilişkisel modeli tanımlandı.
- Sağlık ve iletişim verileri için alan bazlı erişim, açık rıza, veri minimizasyonu, şifreleme ve saklama politikası sınırları kondu.
- Harici işletme verileri için ham veri koruma, kaynak izi, normalizasyon, tekilleştirme, kalite skoru, insan incelemesi ve yeniden doğrulama akışı tasarlandı.

### İşlem tutarlılığı

- Teklif süresi, slot kapasitesi, optimistic version, kısa dağıtık kilit ve idempotency key birlikte ele alındı.
- Rezervasyon ile domain olayının atomik kalması için transaction + outbox yaklaşımı belirlendi.
- Ödeme hareketleri append-only çift taraflı ledger, imzalı webhook, tekrar güvenliği ve sağlayıcı mutabakatıyla modellenmiştir.

### Güven ve operasyon

- Sağlayıcı belgeleri, son kullanma tarihi, manuel VoIP teyidi, doğrulama rozeti, itiraz ve askıya alma akışı ayrıştırıldı.
- WhatsApp pazarlama izni işlemsel bildirimden ayrıldı; opt-out suppression kaydı admin tarafından aşılamaz.
- Walker hizmetinde teslim OTP/QR, hizmet-süreli konum rızası, rota sapması, bağlantı kaybı ve acil eskalasyon tasarlandı.
- Yorum yalnız tamamlanmış rezervasyondan üretilebilir; moderasyon ve uyuşmazlık kararları gerekçeli ve denetlenebilirdir.

### AI sağlık güvenliği

- AI kesin tanı, reçete veya doz üretmez.
- Kırmızı bayrak kuralları modelden önce çalışır; acil riskte AI yanıtı beklenmeden veteriner yönlendirmesi yapılır.
- Şemalı çıktı, güvenli fallback, model/prompt sürümü, regresyon seti, adversarial test ve kullanıcı raporlama döngüsü zorunludur.

### İşletim ve dayanıklılık

- API, worker, queue/DLQ, cache/kilit, obje deposu, geo arama, KMS, audit ve gözlemlenebilirlik bileşenleri ayrıldı.
- Rezervasyon, ödeme webhook'u, kritik bildirim ve olay müdahalesi için ölçülebilir SLO örnekleri tanımlandı.
- Loglarda sağlık verisi, token, kart ve iletişim PII tutulmaması; prod/staging ayrımı, PITR yedek, MFA ve ayrıcalıklı işlem audit'i şart koşuldu.

## Hizmet dikeyleri için özel kurallar

- **Veteriner:** Acil kırmızı bayraklar rezervasyon akışından önce değerlendirilir. Klinik kayıtlar silinmez; düzeltme yeni sürüm olarak eklenir. Sağlayıcı erişimi kapsam ve süreyle sınırlandırılır.
- **Hotel:** Kapasite oda/kafes tipi, pet uygunluğu, çok geceli atomik rezervasyon ve temizlik buffer'ıyla hesaplanır.
- **Kuaför:** Personel yetkinliği, fiziksel istasyon, işlem sırası ve hazırlık süresi birlikte ayrılır.
- **Walker:** Başlangıç/bitiş OTP veya QR, hizmet-süreli konum rızası, rota sapması ve acil eskalasyon gerekir.
- **Pet taksi:** Araç uygunluğu, sürücü belgeleri, geofence, canlı ETA, teslim doğrulama ve bekleme farkı ayrı kurallardır.
- **Sigorta:** Genel ürün bilgisi ile lisans gerektirebilecek aracılık ayrıştırılır; sağlık verisi varsayılan olarak paylaşılmaz.

## Platform sözleşmeleri

- Domain olayları sürümlü ortak envelope kullanır; consumer'lar en az bir kez teslimata karşı idempotenttir.
- Arama sıralaması uygunluk ve güven filtrelerinden sonra çalışır. Sponsorlu sonuçlar filtreleri aşamaz ve açıkça etiketlenir.
- İptal politikası rezervasyon anındaki sürümüyle sabitlenir; sonradan yapılan değişiklikler geriye yürümez.
- Dosya yüklemelerinde magic-byte MIME kontrolü, zararlı yazılım taraması, EXIF temizleme, karantina ve kısa ömürlü bağlantı kullanılır.
- Rezervasyon/ödeme için bölgesel kurtarma hedefi `RPO ≤ 5 dakika`, `RTO ≤ 30 dakika`; audit ve ledger için veri kaybı toleransı yoktur.

## Kurumsal ürün işletimi

- Hesap ve oturum yaşam döngüsü; refresh token rotation, reuse detection, step-up MFA, riskli oturum, askı, itiraz ve anonimleştirme durumlarıyla tanımlandı.
- Pet profili için mükerrer kayıt kontrolü, mikroçip, paylaşımlı bakım yetkileri, sahiplik devri ve hassas kayıp/vefat durumları modellendi.
- Fiyatlar sürümlü fiyat kitabından üretilir; promosyon bütçesi ödeme ile atomikleşir ve kullanıcıya bütün ücret kalemleri gösterilir.
- Risk motoru kupon istismarı, sahte rezervasyon, self-review, kart denemesi ve konum sahteciliğini step-up veya insan incelemesine yönlendirir.
- Sağlayıcı IBAN değişikliği MFA, hesap sahipliği doğrulaması, soğuma süresi ve gerekirse payout dondurma gerektirir.
- Destek temsilcileri PII maskeli bağlamla çalışır; büyük iade, yaptırım kaldırma ve hesap silme çift onaylıdır.
- Kategori ve hizmet alanları sürümlüdür; geriye uyumsuz alan değişikliği yeni sürüm ve kontrollü veri göçü gerektirir.
- Ürün deneyleri güvenlik, iade, şikâyet ve erişilebilirlik guardrail'leriyle otomatik durdurulabilir.
- WCAG 2.2 AA, ekran okuyucu, klavye, metin büyütme, sade dil ve kritik çeviri uzman onayı release kapısına bağlandı.
- KVKK talepleri kimlik doğrulama, veri envanteri, dışa aktarım, anonimleştirme, işlemci bildirimi ve silme kanıtıyla uçtan uca orkestre edilir.

## 3D pet avatar ve AI model platformu

- Kullanıcı yönlendirmeli çok açılı fotoğraf/video çekimi; canlı bulanıklık, ışık, kadraj, örtülme ve pet varlığı kontrolüyle başlar.
- Kaynak medyanın EXIF konumu temizlenir, insan yüzü/PII kontrolü yapılır ve kullanıcı üretimde kullanılacak kareleri onaylar.
- 3D pipeline; pet segmentasyonu, multi-view reconstruction, tür/ırk şekil prior'ı, mesh cleanup, UV, texture, fur, auto-rig, animasyon, LOD ve kalite değerlendirmesini kapsar.
- Sürümlü çıktı paketi GLB/glTF master, mobil LOD'lar, texture atlas, skeleton, blendshape, thumbnail ve provenance manifest içerir.
- Mobil/web runtime cihaz GPU/RAM yeteneğine göre LOD ve texture formatı seçer; streaming, Draco/Meshopt ve KTX2/Basis sıkıştırma kullanır.
- AI Gateway sağlık LLM/RAG, vision, 3D reconstruction, recommendation, fraud ve görsel üretim modellerini görev, izin, güvenlik, maliyet ve gecikme bütçesine göre yönlendirir.
- MLOps yaşam döngüsü data/model card, segment bazlı hata analizi, adversarial test, shadow inference, canary, drift izleme ve otomatik rollback içerir.
- Veteriner RAG yalnız lisans ve güncelliği doğrulanmış kaynakları kullanır; kaynak bulunamazsa model tahmin yürütmez.
- GPU serving interaktif sağlık/vision işlerini batch 3D üretimden öncelikli tutar; kullanıcı kotası, job iptali, checkpoint ve circuit breaker uygular.
- Kaynak pet görselleri varsayılan olarak genel model eğitimine alınmaz. Eğitim için ayrı, açık rıza ve veri provenance kaydı gerekir.
