require_relative "ogrenci"

class DevamsizlikKontrol
  # Ders 10 oturumdur; %30 sınırı = 3 oturum. Karşılaştırma oturum sayısıyla yapılır.
  RISK_SINIRI = 3 # tam 3 riskli sayılır (>=)
  KALMA_SINIRI = 4

  KURALLAR = {
    riskli:       ->(o) { o.devamsizlik >= RISK_SINIRI },
    kaldi:        ->(o) { o.devamsizlik >= KALMA_SINIRI },
    burs_kesilir: ->(o) { o.aktif? && o.devamsizlik >= RISK_SINIRI }
  }.freeze

  def self.durum(ogr)
    KURALLAR.select { |_ad, kural| kural.call(ogr) }.keys
  end
end
