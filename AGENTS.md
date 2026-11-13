# AGENTS.md · Devamsızlık Kural Motoru

## Ortam
- Ruby 3.4 (`.ruby-version`), Linux (WSL Ubuntu). Python veya başka dil YASAK.
- Yalnızca stdlib + Minitest. Gem ve Gemfile yok. Çünkü ödev harici gem'i yasaklar, Minitest stdlib ile gelir.
- Doğrulama: `bin/kontrol` her Write/Edit sonrası kanca olarak OTOMATİK çalışır ve sonucu bildirir. Elle tekrar çalıştırma. YEŞİL görmeden görev BİTMEMİŞTİR.

## Farz etme
- Bu dosyada veya testlerde yazmayan bir alan kuralını FARZ ETME, koda ekleme. Emin değilsen cevapta tek cümleyle sor.

## Dosyalar
- `lib/ogrenci.rb` → `class Ogrenci`
- `lib/devamsizlik_kontrol.rb` → `class DevamsizlikKontrol`
- `test/ogrenci_test.rb` DEĞİŞTİRİLMEZ. Test kırmızıysa kodu düzelt, testi değil.
- Başka dosya ekleme: CLI, CSV, örnek veri, README yok.

## Alan kuralları
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
- `aktif?`, `donduruldu?`, `mezun?` sabit durum listesinden `define_method` ile üretilir. Çünkü liste sonludur; metot grep ile bulunur, `respond_to?` doğru söyler.
- `method_missing` ve `respond_to_missing?` YASAK. Çünkü `mezn?` gibi yazım hatası sessizce `false` döner.
- Standart sınıflar (Integer, String, Date, Object…) açılmaz, yamalanmaz, refine edilmez. Çünkü tüm programı etkiler, metodun kaynağı görünmez.
- Kurallar `DevamsizlikKontrol::KURALLAR` Hash'inde, bu sırayla, lambda olarak durur: `riskli`, `kaldi`, `burs_kesilir`. `instance_eval`/DSL yok. Çünkü kurallar tek yerde okunur, `self` gizlenmez.

## Çıktı
- Son cevap en fazla 3 satır: yazılan dosyalar ve `bin/kontrol` sonucu. Kodu veya kuralları cevapta tekrar anlatma.
