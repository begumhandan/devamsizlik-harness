# AGENTS.md · Devamsızlık Kural Motoru

## Ortam
- Dil: Ruby 3.4 (`.ruby-version`). Python veya başka dil YASAK.
- Yalnızca stdlib + Minitest. Gem ekleme, Gemfile oluşturma.
- Doğrulama: `bin/kontrol`. Çıkış kodu 0 değilse görev BİTMEMİŞTİR.

## Dosyalar
- `lib/ogrenci.rb` → `class Ogrenci`
- `lib/devamsizlik_kontrol.rb` → `class DevamsizlikKontrol`
- `test/ogrenci_test.rb` DEĞİŞTİRİLMEZ. Test kırmızıysa kodu düzelt, testi değil.
- Başka dosya ekleme: CLI, CSV, örnek veri, README yok.

## Alan kuralları (tahmin etme, buradan oku)
- Ders 10 oturumdur. Oran/yüzde hesabı YOK, karşılaştırma oturum sayısıyla yapılır.
- `Ogrenci.new(ad:, durum: :aktif, devamsizlik: 0)`
- `devamsizlik`: Integer, 0..10. Dışındaki her değer → `ArgumentError`.
- `durum`: yalnızca `:aktif`, `:donduruldu`, `:mezun`. Başkası → `ArgumentError`.
- `:riskli` ⇔ `devamsizlik >= 3`. **TAM 3 RİSKLİDİR** (%30 dahil). `>` YAZMA.
- `:kaldi` ⇔ `devamsizlik >= 4`.
- `:burs_kesilir` ⇔ `durum == :aktif` VE `devamsizlik >= 3`.
- Kurallar birbirini dışlamaz: 4 devamsızlıklı aktif öğrenci üç kurala da girer.
- `DevamsizlikKontrol.durum(ogr)` → eşleşen kural adlarının Symbol dizisi, yoksa `[]`.

## Kod kuralları
- `aktif?`, `donduruldu?`, `mezun?` sabit bir durum listesi üzerinden `define_method` ile üretilir.
- `method_missing` ve `respond_to_missing?` YASAK.
- Standart sınıflar (Integer, String, Date, Object…) açılmaz, yamalanmaz, refine edilmez.
- Kurallar `DevamsizlikKontrol::KURALLAR` Hash'inde, bu sırayla, lambda olarak durur:
  `riskli`, `kaldi`, `burs_kesilir`. `instance_eval`/DSL yok.
