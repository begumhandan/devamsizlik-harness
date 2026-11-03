# Devamsızlık Kural Motoru · Harness Ödevi (YZM379)

Ruby 3.4 ile yazılmış bir öğrenci devamsızlık kural motoru. `lib/` altındaki kodu **ajan** (Claude Code) yazdı. Bu repo, ajanın doğru kodu yazmasını sağlayan **harness**'ı (rehber + sensör + ratchet) ve bu harness'ın etkisini ölçen A/B koşularını içeriyor.

> Ajan = Model + Harness. Model üç koşuda da aynıydı. Değişen tek şey harness'tı.

## Çalıştırma

```bash
ruby -v                           # 3.4.x
bin/kontrol; echo $?              # 0 = tüm testler yeşil
ruby -Ilib test/ogrenci_test.rb   # testleri ayrıntılı görmek için
```

```ruby
require_relative "lib/devamsizlik_kontrol"
ogr = Ogrenci.new(ad: "Ayşe", devamsizlik: 3)
DevamsizlikKontrol.durum(ogr)   # => [:riskli, :burs_kesilir]
ogr.aktif?                      # => true
```

**rbenv notu:** `.ruby-version` dosyası ödevin istediği gibi `3.4` içeriyor. rbenv bu kısa sürüm adını kendisi çözemez. Kurulu 3.4.x sürümü için bir kez `ln -s 3.4.12 ~/.rbenv/versions/3.4` çalıştırılmalı. mise ve chruby bu adımı gerektirmez.

## Kurallar

Ders 10 oturumdur. Karşılaştırma oran üzerinden değil oturum sayısıyla yapılır.

| Kural | Koşul | Not |
|---|---|---|
| `:riskli` | `devamsizlik >= 3` | **Tam 3 (%30) riskli sayılır** |
| `:kaldi` | `devamsizlik >= 4` | |
| `:burs_kesilir` | `durum == :aktif` ve `devamsizlik >= 3` | Özgün kural: burs yalnızca aktif öğrenciye verildiği için dondurulmuş ve mezun öğrenciye uygulanmaz |

Kurallar birbirini dışlamaz. 4 devamsızlığı olan aktif öğrenci üç kurala birden girer.

## Harness

| Parça | Dosya | Görev |
|---|---|---|
| Rehber | `AGENTS.md` (+ `CLAUDE.md` → `AGENTS.md` symlink) | Sürüm, alan kuralları, yasaklar. Sadece ajanın tahmin edeceği şeyler yazılı |
| Sensör | `test/ogrenci_test.rb` | 19 test: sınır vakaları (2, 3, 4), veri sözleşmesi, `define_method`, `method_missing` ve monkey patch için statik yasak testleri |
| Kanca | `bin/kontrol` + `.claude/settings.json` | Her Write/Edit sonrası testleri otomatik çalıştırır, sonucu ajana bildirir |
| Sensör koruması | `.claude/settings.json` → `deny: Edit/Write(test/**)` | Ajan testi değiştirerek "geçemez" |
| Ratchet | `RATCHET_LOG.md` | Her hata → kalıcı kural veya test |

### `bin/kontrol` kancası

`.claude/settings.json` dosyası `bin/kontrol`'ü Claude Code'un **PostToolUse** kancası olarak tanımlıyor (`matcher: "Write|Edit"`). Ajan bir dosyayı her kaydettiğinde testler arka planda çalışır:

| Sonuç | Çıkış kodu | Ajana ne gider |
|---|---|---|
| KIRMIZI | `2` | Test çıktısının son 30 satırı (stderr). Claude Code bunu ajanın önüne koyar |
| YEŞİL | `0` | `additionalContext` JSON'u: `bin/kontrol YESIL: 19 runs, 61 assertions, 0 failures...` |

Her çalışma `log/kontrol.log` dosyasına saatle birlikte yazılır. Koşulardaki günlükler `kosular/*_kontrol.log` altında. Claude Code dışındaki ajanlarda `bin/kontrol` elle çalıştırılmalı.

## A/B Koşusu ve Ölçüm Raporu

**Ortak koşullar:** Model `claude-opus-5-5`, Claude Code 2.1.317 (`claude -p`), WSL Ubuntu, Ruby 3.4.12.

**Prompt (bütün koşularda aynı):** `Öğrenci devamsızlık kontrolü yap, devamsızlık sınırı %30'dur.`

| Koşu | Klasör içeriği | İzin bayrakları |
|---|---|---|
| A0 | Boş | Yok (varsayılan) |
| A1 | Boş | `acceptEdits` + `Bash(ruby/python3/ls/cat)` |
| B | Harness (Ratchet 1) | A1 + `Bash(bin/kontrol)` |
| B2 | Harness (Ratchet 2) | B ile aynı |

A0 ölçümden çıkarıldı: `-p` modunda dosya yazma izni olmadığı için 3 araç çağrısı reddedildi ve kod diske yazılamadı. Hata davranışı yine de kayıtlı ve A1 ile aynı.

### Sonuçlar

| Ölçüm | A1 | B | B2 | A1 → B2 |
|---|---|---|---|---|
| Ödev kuralları (riskli / kaldi / burs) | 0/3 | 3/3 | 3/3 | |
| Dil | Python | Ruby | Ruby | |
| Ödev sensörü (19 test) | çalıştırılamaz | 19/19 | 19/19 | |
| Sınırda `>= 3` | ✘ (`>`) | ✔ | ✔ | |
| **Tur (`num_turns`)** | 6 | 7 | **4** | **−33%** |
| İzin reddi | 0 | 1 | 0 | |
| Kanca çalışması | – | 2 (K → Y) | 2 (K → Y) | |
| Çıktı tokenı | 4.059 | 2.274 | 2.017 | **−50%** |
| Cache oluşturma (sabit bağlam) | 17.624 | 18.781 | 19.346 | +10% |
| Cache okuma | 77.873 | 111.594 | 57.497 | −26% |
| Girdi tarafı toplam | 95.505 | 130.384 | 76.849 | **−20%** |
| Maliyet (USD) | 0,2378 | 0,2181 | 0,2066 | **−13%** |
| Süre (sn) | 58,8 | 29,8 | 20,3 | **−65%** |

### Bulgular

1. **Sınır hatası tekrarlanabilirdi, harness onu sıfırladı.** A0 ve A1'in ikisinde de ajan sınırda `>` yazdı ve tam %30'u "geçti" saydı. B ve B2'de bu hata hiç görülmedi. Ajan iki dosyayı da tek seferde doğru yazdı.
2. **Ajanın kendi yazdığı test yanlışı kilitledi.** A1'de ajan `assertFalse(kaldi_mi(10, 3))` testini yazdı. Testler yeşildi ama kural yanlıştı. Sensör alan bilgisinden gelmeli, ajandan değil. Bu yüzden test dosyası insan tarafından yazıldı ve ajana kilitlendi.
3. **Rehber sabit bağlamı büyüttü ama toplamda kazandırdı.** Cache oluşturma %10 arttı. Tur sayısı düşünce her turda tekrar okunan bağlam azaldı ve toplam girdi bile %20 düştü.
4. **İlk harness turu artırdı (6 → 7).** Kanca sadece hatayı bildiriyordu. Ajan testlerin geçtiğini duymadığı için elle iki kez doğruladı, bir doğrulaması da izin reddine takıldı. Bu bir harness hatasıydı. Ratchet 2 ile kanca YEŞİL sonucu da bildirince tur 4'e indi (B → B2: −43%).
5. **KIRMIZI kayıtlar mantık hatası değil.** B ve B2'deki tek KIRMIZI, ilk dosya yazıldığında ikinci dosyanın henüz olmamasından kaynaklandı (`LoadError`).

### Kanıt dosyaları

| Dosya | İçerik |
|---|---|
| `kosular/a0_sonuc_izin_reddi.json` | A0 ham sonucu, reddedilen araç çağrılarıyla birlikte |
| `kosular/a1_sonuc.json`, `kosular/a1_kod/` | A1 ham sonucu ve ajanın yazdığı Python kodu |
| `kosular/b_akis.jsonl`, `b_sonuc.json`, `b_kontrol.log`, `b_kod/` | B'nin tam akış kaydı, sonucu, kanca günlüğü ve kodu |
| `kosular/b2_akis.jsonl`, `b2_sonuc.json`, `b2_kontrol.log`, `b2_kod/` | B2 için aynısı. `lib/` bu koşunun kodu |

Git geçmişi sırası: A kanıtları → Ratchet 1 → B kanıtları → Ratchet 2 → B2 kanıtları. Her ratchet, kendisini doğuran koşudan sonra ve bir sonraki koşudan önce commit edildi.

## Yapamadıklarım

- **Her koşu tek kez yapıldı.** Model çıktısı deterministik değil. A için iki deneme (A0, A1) aynı hatayı verdi, ama B ve B2 tek ölçüm. Sayılar eğilimi gösteriyor,
istatistiksel güven vermiyor.
- **A'da `method_missing` ve monkey patch gözlenemedi.** Ajan hiç sınıf yazmadığı için bu yasaklar A'da test edilemedi. Önleyici kural ve test olarak eklendi, günlükte "gözlenmedi" diye işaretlendi.
- **A0 geçersiz.** İzin ayarı yüzünden kod diske yazılamadı ve koşu tekrarlandı (A1).
- **Koşular arasında izin bayrağı farkı var.** B ve B2'ye `Bash(bin/kontrol)` izni eklendi. Bu izin harness'ın bir parçası, ama A1 ile birebir aynı koşullar değil.
- **`ad` alanı doğrulanmıyor.** `nil` ya da boş ad kabul ediliyor, testi de yok.
- **Statik yasak testleri regex tabanlı.** Doğrudan yazılmış `class Integer` ya da `method_missing` yakalanıyor, ama `Object.const_get(:Integer).class_eval` gibi dolaylı yollar atlatabilir.
- **RuboCop eklenmedi.** Slaytta stil sensörü olarak geçiyor, ancak harici gem olduğu için ödevin "yalnızca stdlib + Minitest" kuralıyla kapsam dışında bırakıldı.
- **Kanca yalnızca Claude Code'da otomatik.** Diğer ajanlarda `bin/kontrol` elle çalıştırılmalı.
