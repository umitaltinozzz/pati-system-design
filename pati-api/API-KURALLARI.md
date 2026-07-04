# Pati API Kuralları

- Base URL: `/v1`
- Kimlik: `Authorization: Bearer <access-token>`
- Yazma istekleri: `Idempotency-Key` zorunlu (`POST /quotes` hariç tavsiye, rezervasyon/ödeme/AI'da zorunlu)
- İzleme: istemci `X-Request-Id` gönderebilir; sunucu her cevapta döndürür
- Zaman: RFC 3339 UTC
- Para: JSON string decimal + `currency`
- Pagination: cursor tabanlı `page[cursor]`, `page[limit]`
- Hata: RFC 9457 uyumlu `application/problem+json`
- Optimistic concurrency: güncellemelerde `If-Match` veya body `version`
- Dosya: önce upload session, sonra signed URL ile doğrudan obje deposu
- Webhook: timestamp + HMAC imza + event ID replay koruması
- Geriye uyumluluk: `/v1` içinde alan silinmez veya anlamı değiştirilmez; yeni alan opsiyonel eklenir

