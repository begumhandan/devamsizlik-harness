require_relative "ogrenci"

# Ders 10 oturumdur; %30 sınırı = 3 oturum. Karşılaştırma oturum sayısıyla yapılır.
class DevamsizlikKontrol
  KURALLAR = {
    riskli:       ->(o) { o.devamsizlik >= 3 },
    kaldi:        ->(o) { o.devamsizlik >= 4 },
    burs_kesilir: ->(o) { o.aktif? && o.devamsizlik >= 3 }
  }.freeze

  def self.durum(ogr)
    KURALLAR.select { |_ad, kural| kural.call(ogr) }.keys
  end
end
