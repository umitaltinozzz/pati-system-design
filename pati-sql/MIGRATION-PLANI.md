# Pati Veritabanı Migration Planı

## Strateji

- Migration'lar numaralı, ileri yönlü ve değiştirilemezdir.
- Her migration önce staging kopyasında gerçekçi veri hacmiyle çalıştırılır.
- Uygulama dağıtımları **expand → migrate/backfill → switch → contract** sırasını izler.
- Uzun tablo kilidi yaratabilecek DDL ayrı bakım penceresinde veya `NOT VALID` + `VALIDATE CONSTRAINT` yaklaşımıyla yürütülür.
- Büyük indeksler üretimde `CREATE INDEX CONCURRENTLY` ile transaction dışında eklenir.

## İlk kurulum

1. PostgreSQL 16 oluşturulur; UTC, statement timeout ve bağlantı havuzu ayarlanır.
2. Migration `001–006` sırayla tek migration rolüyle uygulanır.
3. Uygulama rolleri oluşturulur; migration rolü uygulamaya verilmez.
4. Seed olarak şehir, ilçe, tür, ırk ve kategori lookup verileri yüklenir.
5. Şema smoke testleri ve FK indeks denetimi çalıştırılır.

## Sürümleme kuralları

- Sütun yeniden adlandırılmaz: yeni sütun ekle, çift yaz, backfill et, okumayı geçir, eskiyi sonraki sürümde kaldır.
- Enum benzeri durumlar `text + check` kullanır; yeni durum önce DB'ye, sonra uygulamaya açılır.
- `NOT NULL` önce nullable sütun, backfill, doğrulama ve son olarak constraint şeklinde eklenir.
- Finansal ve audit tablolarında silme/güncelleme yapılmaz; ters kayıt üretilir.
- Backfill işleri küçük batch'ler, sabit sıralama ve checkpoint ile çalışır.

## Operasyon kapıları

- Migration öncesi: yedek/PITR doğrulaması, disk kapasitesi, replica lag, lock ve uzun sorgu kontrolü.
- Migration sırasında: lock wait, deadlock, CPU/IO, replication lag ve hata oranı alarmı.
- Migration sonrası: satır sayısı, null oranı, FK orphan kontrolü, index kullanımı ve uygulama sentetik testleri.

## Geri dönüş

Veri kaybettiren otomatik `down` migration yoktur. Uygulama önceki şemayla uyumlu tutulur. Sorunda trafik eski uygulamaya döner ve yeni sütun/tablo yerinde kalır; düzeltme yeni forward migration olarak çıkar.

