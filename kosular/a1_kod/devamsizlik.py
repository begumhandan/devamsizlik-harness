"""Öğrenci devamsızlık kontrolü.

Devamsızlık sınırı %30'dur. Devamsızlık oranı %30'u AŞAN öğrenci
devamsızlıktan kalır; tam %30 sınır içinde kabul edilir.

Kullanım:
    python3 devamsizlik.py                 # etkileşimli mod
    python3 devamsizlik.py ogrenciler.csv  # toplu kontrol

CSV biçimi (başlık satırı zorunlu):
    ad,toplam_ders,devamsiz
    Ali Yılmaz,42,10
"""

import csv
import sys

SINIR_YUZDE = 30


def devamsizlik_orani(toplam_ders: int, devamsiz: int) -> float:
    """Devamsızlık oranını yüzde olarak döndürür."""
    _dogrula(toplam_ders, devamsiz)
    return devamsiz * 100 / toplam_ders


def kaldi_mi(toplam_ders: int, devamsiz: int) -> bool:
    """Devamsızlık %30'u aşıyorsa True döndürür.

    Kayan nokta yuvarlama hatası olmasın diye tam sayılarla karşılaştırır.
    """
    _dogrula(toplam_ders, devamsiz)
    return devamsiz * 100 > toplam_ders * SINIR_YUZDE


def kalan_hak(toplam_ders: int, devamsiz: int) -> int:
    """Sınırı aşmadan daha kaç ders kaçırılabileceğini döndürür (en az 0)."""
    _dogrula(toplam_ders, devamsiz)
    izin_verilen = toplam_ders * SINIR_YUZDE // 100
    return max(0, izin_verilen - devamsiz)


def _dogrula(toplam_ders: int, devamsiz: int) -> None:
    if toplam_ders <= 0:
        raise ValueError("Toplam ders sayısı pozitif olmalıdır.")
    if devamsiz < 0:
        raise ValueError("Devamsızlık negatif olamaz.")
    if devamsiz > toplam_ders:
        raise ValueError("Devamsızlık toplam ders sayısından büyük olamaz.")


def rapor(ad: str, toplam_ders: int, devamsiz: int) -> str:
    oran = devamsizlik_orani(toplam_ders, devamsiz)
    if kaldi_mi(toplam_ders, devamsiz):
        durum = "KALDI (devamsızlık sınırı aşıldı)"
    else:
        durum = f"GEÇTİ (kalan hak: {kalan_hak(toplam_ders, devamsiz)} ders)"
    return f"{ad}: {devamsiz}/{toplam_ders} ders devamsız, %{oran:.1f} -> {durum}"


def csv_kontrol(dosya_yolu: str) -> int:
    """CSV dosyasındaki tüm öğrencileri kontrol eder; kalan öğrenci sayısını döndürür."""
    kalan = 0
    with open(dosya_yolu, newline="", encoding="utf-8") as f:
        for satir_no, satir in enumerate(csv.DictReader(f), start=2):
            try:
                ad = satir["ad"].strip()
                toplam = int(satir["toplam_ders"])
                devamsiz = int(satir["devamsiz"])
                print(rapor(ad, toplam, devamsiz))
                if kaldi_mi(toplam, devamsiz):
                    kalan += 1
            except (KeyError, ValueError, TypeError, AttributeError) as e:
                print(f"Satır {satir_no} atlandı: {e}", file=sys.stderr)
    print(f"\nDevamsızlıktan kalan öğrenci sayısı: {kalan}")
    return kalan


def _tam_sayi_oku(mesaj: str) -> int:
    while True:
        try:
            return int(input(mesaj))
        except ValueError:
            print("Lütfen geçerli bir tam sayı girin.")


def etkilesimli() -> None:
    ad = input("Öğrenci adı: ").strip() or "Öğrenci"
    while True:
        toplam = _tam_sayi_oku("Toplam ders sayısı: ")
        devamsiz = _tam_sayi_oku("Devamsız olunan ders sayısı: ")
        try:
            print(rapor(ad, toplam, devamsiz))
            return
        except ValueError as e:
            print(f"Hata: {e}")


if __name__ == "__main__":
    if len(sys.argv) > 1:
        csv_kontrol(sys.argv[1])
    else:
        etkilesimli()
