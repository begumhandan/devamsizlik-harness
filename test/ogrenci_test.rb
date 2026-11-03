# Sensör: alan kuralları ve kod yasakları. Ajan bu dosyayı DEĞİŞTİREMEZ.
require "minitest/autorun"
require_relative "../lib/ogrenci"
require_relative "../lib/devamsizlik_kontrol"

class OgrenciTest < Minitest::Test
  LIB = File.expand_path("../lib", __dir__)

  def ogr(devamsizlik: 0, durum: :aktif)
    Ogrenci.new(ad: "Test", durum: durum, devamsizlik: devamsizlik)
  end

  def kurallar(o) = DevamsizlikKontrol.durum(o).sort

  # --- Veri sözleşmesi ---
  def test_varsayilanlar
    o = Ogrenci.new(ad: "Ali")
    assert_equal ["Ali", :aktif, 0], [o.ad, o.durum, o.devamsizlik]
  end

  def test_devamsizlik_0_ile_10_arasinda_olmali
    assert_equal 10, ogr(devamsizlik: 10).devamsizlik
    [-1, 11].each { |d| assert_raises(ArgumentError) { ogr(devamsizlik: d) } }
  end

  def test_devamsizlik_tam_sayi_olmali
    ["3", 3.0, nil].each { |d| assert_raises(ArgumentError) { ogr(devamsizlik: d) } }
  end

  def test_gecersiz_durum_reddedilir
    assert_raises(ArgumentError) { ogr(durum: :silindi) }
  end

  # --- Durum sorguları: gerçek metot, dürüst respond_to? ---
  def test_durum_sorgulari_dogru_cevap_verir
    %i[aktif donduruldu mezun].each do |d|
      o = ogr(durum: d)
      %i[aktif donduruldu mezun].each do |s|
        assert_equal d == s, o.public_send(:"#{s}?"), "#{d} için #{s}?"
      end
    end
  end

  def test_durum_sorgulari_gercek_metot
    %i[aktif? donduruldu? mezun?].each do |m|
      assert_includes Ogrenci.instance_methods(false), m
    end
  end

  def test_bilinmeyen_metot_sessizce_false_donmez
    assert_raises(NoMethodError) { ogr.mezn? }
    refute ogr.respond_to?(:mezn?)
  end

  # --- Kurallar: SINIR VAKALARI ---
  def test_devamsizlik_2_hicbir_kurala_girmez
    assert_equal [], kurallar(ogr(devamsizlik: 2))
  end

  def test_devamsizlik_tam_3_riskli_sayilir
    assert_includes kurallar(ogr(devamsizlik: 3)), :riskli
  end

  def test_devamsizlik_3_kaldi_degildir
    refute_includes kurallar(ogr(devamsizlik: 3)), :kaldi
  end

  def test_devamsizlik_tam_4_kaldi_sayilir
    assert_includes kurallar(ogr(devamsizlik: 4)), :kaldi
  end

  def test_aktif_ogrenci_tam_3_te_burs_kesilir
    assert_includes kurallar(ogr(devamsizlik: 3)), :burs_kesilir
  end

  def test_aktif_ogrenci_2_de_burs_kesilmez
    refute_includes kurallar(ogr(devamsizlik: 2)), :burs_kesilir
  end

  def test_aktif_olmayana_burs_kesilir_uygulanmaz
    %i[donduruldu mezun].each do |d|
      assert_equal %i[kaldi riskli], kurallar(ogr(devamsizlik: 4, durum: d))
    end
  end

  def test_tum_degerler_tablosu
    beklenen = {
      0 => [], 1 => [], 2 => [],
      3 => %i[burs_kesilir riskli],
      4 => %i[burs_kesilir kaldi riskli]
    }
    (0..10).each do |d|
      assert_equal beklenen.fetch(d, beklenen[4]), kurallar(ogr(devamsizlik: d)), "devamsizlik=#{d}"
    end
  end

  def test_kurallar_hash_te_lambda_olarak_durur
    assert_equal %i[riskli kaldi burs_kesilir], DevamsizlikKontrol::KURALLAR.keys
    assert DevamsizlikKontrol::KURALLAR.values.all?(Proc)
  end

  # --- Kod yasakları (statik sensör) ---
  def kaynak = Dir[File.join(LIB, "**", "*.rb")].map { File.read(_1) }.join("\n")

  def test_method_missing_yasak
    refute_match(/method_missing|respond_to_missing\?/, kaynak)
  end

  def test_standart_sinif_yamasi_yasak
    std = "Integer|String|Symbol|Date|Time|Array|Hash|Object|Kernel|Numeric|Comparable"
    refute_match(/^\s*(class|module)\s+(#{std})\b/, kaynak)
    refute_match(/\b(#{std})\.(class_eval|class_exec|prepend|include|define_method)\b/, kaynak)
    refute_match(/\brefine\b/, kaynak)
  end

  def test_durum_sorgulari_define_method_ile_uretilir
    assert_match(/define_method/, File.read(File.join(LIB, "ogrenci.rb")))
  end
end
