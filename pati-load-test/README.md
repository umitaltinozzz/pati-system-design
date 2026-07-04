# Pati Postman/Newman Yük Testi

Bu paket staging ortamında `1.000`, `5.000` veya `10.000` toplam collection iterasyonu çalıştırır.

## Ön koşullar

1. Node.js ve `npx`
2. Staging API ve izole test verisi
3. Environment dosyasında gerçek staging `baseUrl`, token ve UUID değerleri
4. API/DB/Redis/NATS/worker metriklerinin açık olması

## Postman uygulaması

Şu iki dosyayı import edin:

- `Pati-Load-Test.postman_collection.json`
- `Pati-Staging.postman_environment.json`

Collection Runner'da varsayılan `01 Read-only Load Path` klasörünü seçin. Postman Runner iterasyonları sıralı çalıştırır; gerçek paralel yük için aşağıdaki Newman runner kullanılmalıdır.

## Paralel Newman çalıştırma

```powershell
# Baseline: 1.000 iterasyon / 10 worker
.\Run-NewmanLoad.ps1 -TotalIterations 1000 -Workers 10

# Orta yük: 5.000 iterasyon / 25 worker
.\Run-NewmanLoad.ps1 -TotalIterations 5000 -Workers 25

# Yüksek yük: 10.000 iterasyon / 50 worker
.\Run-NewmanLoad.ps1 -TotalIterations 10000 -Workers 50
```

Her iterasyon dört HTTP isteği üretir. Dolayısıyla varsayılan read-only yol yaklaşık olarak:

| Seviye | Iterasyon | HTTP isteği | Önerilen worker |
|---|---:|---:|---:|
| Baseline | 1.000 | 4.000 | 10 |
| Orta | 5.000 | 20.000 | 25 |
| Yüksek | 10.000 | 40.000 | 50 |

## Kabul eşikleri

- HTTP hata oranı `< %1`
- `p95 < 800 ms`
- `p99 < 1.500 ms`
- Availability endpoint `p95 < 1.000 ms`
- Test boyunca DB connection pool `< %80`
- PostgreSQL lock wait p95 `< 100 ms`
- Redis/NATS hata oranı `0`
- API pod CPU sürekli `< %75`, bellek OOM olmamalı
- Test bitiminden sonra kuyruk backlog'u 5 dakika içinde sıfırlanmalı

## Yazma testi

`99 Write Path` varsayılan olarak runner tarafından engellenir. Yalnız ödeme sandbox'ı ve her koşudan sonra temizlenen izole veritabanında:

```powershell
.\Run-NewmanLoad.ps1 -TotalIterations 1000 -Workers 10 -Folder '99 Write Path — EXPLICIT OPT-IN' -AllowWrites
```

Üretim ortamında veya gerçek ödeme yöntemiyle çalıştırmayın. 10.000 yazma iterasyonu slot, rezervasyon, ödeme ve bildirim kayıtları üretir; test verisi temizleme/partition stratejisi önceden hazırlanmalıdır.

## Sınır

Newman paralel process yaklaşımı trafik üretir ancak hassas arrival-rate, VU ramp ve coordinated omission analizi sağlamaz. Kapasite kabul testi için aynı OpenAPI akışının k6 veya Gatling sürümü ayrıca yazılmalıdır.

