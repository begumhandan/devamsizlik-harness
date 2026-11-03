# Ratchet Günlüğü

Kanıtlar: `kosular/a0_sonuc_izin_reddi.json`, `kosular/a1_sonuc.json`, `kosular/a1_kod/`.
Model: claude-opus-5-5 · Ajan: Claude Code 2.1.317 (`claude -p`) · Ortam: WSL Ubuntu, Ruby 3.4.12.

| Tarih | Karşılaşılan hata | Yakalandığı koşu | Kalıcı kural / test | Katman |
|---|---|---|---|---|
| 2026-11-03 | Dosya yazma ve komut çalıştırma izni reddedildi (3 ret), kod diske yazılamadı | A0 | Koşu komutuna `--permission-mode acceptEdits` ve `--allowedTools` eklendi | Altyapı |
| 2026-11-03 | Ruby yerine Python yazdı (`devamsizlik.py`, `unittest`) | A0, A1 | AGENTS.md: "Ruby 3.4, Python YASAK" + `.ruby-version`; sensör Minitest olduğu için Python çözümü geçemez | Rehber + Sensör |
| 2026-11-03 | Sınırda `>` kullandı, tam %30'u (10'da 3) geçer saydı | A0, A1 | AGENTS.md: "TAM 3 RİSKLİDİR, `>` YAZMA"; `test_devamsizlik_tam_3_riskli_sayilir`, `test_tum_degerler_tablosu` | Rehber + Sensör |
| 2026-11-03 | Kendi yazdığı test hatalı kuralı kilitledi: `assertFalse(kaldi_mi(10, 3))` | A0, A1 | Testi insan yazar; AGENTS.md: "test DEĞİŞTİRİLMEZ"; `.claude/settings.json`: `deny Edit/Write(test/**)` | Rehber + Sensör |
| 2026-11-03 | %30'u kalma sınırı sandı, `riskli`/`kaldi` ayrımı yok | A0, A1 | AGENTS.md alan kuralları; `test_devamsizlik_3_kaldi_degildir`, `test_devamsizlik_tam_4_kaldi_sayilir` | Rehber + Sensör |
| 2026-11-03 | Sabit 10 oturum yerine değişken ders sayısı ve oran hesabı | A0, A1 | AGENTS.md: "10 oturum, oran yok, 0..10"; `test_devamsizlik_0_ile_10_arasinda_olmali`, `test_devamsizlik_tam_sayi_olmali` | Rehber + Sensör |
| 2026-11-03 | `Ogrenci` sınıfı ve durum alanı (`:aktif` vb.) yok | A0, A1 | AGENTS.md dosya ve sınıf sözleşmesi; `test_varsayilanlar`, `test_durum_sorgulari_*`, `test_gecersiz_durum_reddedilir` | Rehber + Sensör |
| 2026-11-03 | İstenmeyen ek özellik: CSV toplu kontrol ve örnek veri | A1 | AGENTS.md: "Başka dosya ekleme" | Rehber |
| 2026-11-03 | *Gözlenmedi (A'da sınıf yazılmadı)*. Önleyici: `method_missing` | – | AGENTS.md yasağı; `test_method_missing_yasak`, `test_bilinmeyen_metot_sessizce_false_donmez` | Rehber + Sensör |
| 2026-11-03 | *Gözlenmedi (A'da sınıf yazılmadı)*. Önleyici: standart sınıfa monkey patch | – | AGENTS.md yasağı; `test_standart_sinif_yamasi_yasak` | Rehber + Sensör |
| 2026-11-03 | Kanca yalnız hatayı bildiriyordu, YEŞİL sonuç ajana ulaşmadı. Ajan testleri elle 2 kez tekrar çalıştırdı (+2 tur) | B | `bin/kontrol`: YEŞİL durumda `additionalContext` JSON ile sonucu ajana bildirir. AGENTS.md: "kanca otomatik çalışır, elle tekrar çalıştırma" | Sensör + Rehber |
| 2026-11-03 | Elle doğrulama için zincirli komut (`bin/kontrol; echo ...; ... \| tail`) izin reddine takıldı (+1 tur) | B | Üstteki madde: elle doğrulama gereksizleşince zincirli komut ihtiyacı kalkar | Rehber |

| 2026-11-03 | Yeni hata gözlenmedi. Elle doğrulama ve izin reddi tekrarlanmadı (B: 7 tur → B2: 4 tur) | B2 | – (Ratchet 2 doğrulandı) | – |
