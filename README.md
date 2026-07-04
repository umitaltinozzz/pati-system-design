# Pati — Profesyonel Sistem Tasarımı

Pet care super app için ürün, backend, PostgreSQL, OpenAPI, güvenlik, operasyon ve AI/3D mimari paketidir.

Yazılımcıya doğrudan teslim için başlangıç belgesi: [`YAZILIMCI-HANDOFF.md`](YAZILIMCI-HANDOFF.md).

## Başlangıç

- `index.html` — altı bölümde sıralanmış 60 UML görünümü
- `YAZILIMCI-HANDOFF.md` — uygulama sırası ve Definition of Done
- `PATI-MIMARI.md` — mimari kararların yazılı özeti
- `pati-api/openapi.yaml` — doğrulanmış OpenAPI 3.1.2 sözleşmesi
- `pati-api/SERVIS-SINIRLARI.md` — modül sahipliği ve transaction sınırları
- `pati-api/TEKNOLOJI-YIGINI.md` — kesin teknoloji seçimi
- `pati-sql/migrations/` — PostgreSQL migration seti
- `pati/` — PlantUML kaynakları ve yerel SVG çıktıları

## Pati profesyonel derin analiz seti

Karşılaştırmalı dokuz görünümün altında Pati için on bir ek üretim mimarisi diyagramı bulunur:

10. Çekirdek domain veri modeli ve ilişkiler
11. Sağlayıcı onboarding, belge ve doğrulama
12. Takvim, slot kilidi, idempotency ve çifte rezervasyon koruması
13. Ödeme ledger'ı, komisyon, hak ediş, iade ve mutabakat
14. İşletme veri toplama, provenance, tekilleştirme ve kalite pipeline'ı
15. VoIP doğrulama, iletişim izni ve WhatsApp suppression zinciri
16. Walker canlı konum, teslim doğrulama ve acil olay akışı
17. AI sağlık asistanı güvenlik sınırı ve acil yönlendirme
18. Çok kanallı bildirim orkestrasyonu
19. Yorum doğrulama, moderasyon, şikâyet ve uyuşmazlık
20. Gözlemlenebilirlik, SLO, alarm ve olay müdahalesi
21. Hizmet dikeyleri ve ortak platform yetkinlik haritası
22. Veteriner randevusu, hassas sağlık kaydı ve erişim yaşam döngüsü
23. Hotel oda/kafes ve kuaför personel/istasyon kapasite planlama
24. Pet taksi fiyatlama, dispatch, teslim doğrulama ve canlı yolculuk
25. Sigorta yönlendirmesi ve alan bazlı veri paylaşım rızası
26. Geo arama, uygunluk filtresi ve açıklanabilir sıralama
27. İptal, no-show, mücbir sebep ve iade politika motoru
28. Domain event envelope, şema sürümleme ve idempotent consumer kuralları
29. Güvenlik ve mahremiyet tehdit modeli
30. Yedekleme, bölgesel felaket kurtarma, RPO ve RTO
31. Kimlik doğrulama, oturum güvenliği ve hesap yaşam döngüsü
32. Pet kimliği, mükerrer profil, ortak bakım ve sahiplik devri
33. Fiyat kitabı, promosyon bütçesi, komisyon ve vergi hesaplama
34. Sahtecilik, kötüye kullanım, step-up ve insan incelemesi
35. Sağlayıcı ödeme hesabı, vergi, hak ediş ve mutabakat
36. Çok kanallı müşteri destek ve CRM vaka yönetimi
37. Sürümlü kategori/hizmet kataloğu ve veri göçü yönetişimi
38. Ürün analitiği, KPI, deney ataması ve güvenlik guardrail'leri
39. WCAG erişilebilirlik, lokalizasyon ve kritik içerik onayı
40. KVKK veri erişimi, dışa aktarım, düzeltme ve silme orkestrasyonu
41. Fotoğraf/video çekim rehberi ve 3D avatar onboarding
42. Segmentasyon, reconstruction, mesh, texture, fur, rig, animasyon ve LOD pipeline'ı
43. Mobil/web glTF viewer, cihaz LOD seçimi, animasyon, aksesuar ve AR
44. Sağlık, vision, 3D, öneri, fraud ve maskot modelleri için AI gateway/router
45. Veri kartı, model kartı, evaluation, shadow, canary, drift ve rollback MLOps süreci
46. Veteriner onaylı kaynaklarla sürümlü RAG bilgi altyapısı
47. Açıklanabilir, izinli ve adalet guardrail'li kişiselleştirme
48. AI risk sınıfları, insan incelemesi, itiraz ve kill switch
49. Realtime/batch GPU kuyrukları, autoscaling, fallback ve maliyet kontrolü
50. Kaynak medya, 3D artefact, sağlık girdisi ve eğitim verisi saklama yönetişimi
51. PostgreSQL şema domain ER haritası
52. Rezervasyon, ödeme, ledger, payout, review ve dispute ayrıntılı SQL ERD
53. Kesin teknoloji yığını ve Kubernetes üretim deployment
54. Modüler monolit domain ve servis sınırları
55. Kayıt, giriş, risk kontrolü ve refresh token rotation sequence
56. Teklif, slot kilidi ve idempotent rezervasyon sequence
57. İmzalı ödeme webhook, ledger ve rezervasyon geçişi sequence
58. Upload, izin, AI/3D job, GPU worker ve sonuç sequence
59. Transactional outbox, NATS ve Temporal domain event entegrasyonu
60. API doğrulama, yetki, idempotency ve RFC 9457 hata sözleşmesi

## Kapsam sınırı

Bu repository hedef mimari ve uygulama sözleşmesidir; çalışan ürün kaynak kodu değildir. Hukuki ve veterinerlik kararları ilgili uzman onayından geçmelidir.
