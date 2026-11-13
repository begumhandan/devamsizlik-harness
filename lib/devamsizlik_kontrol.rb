class DevamsizlikKontrol
  KURALLAR = {
    riskli:       ->(ogr) { ogr.devamsizlik >= 3 },
    kaldi:        ->(ogr) { ogr.devamsizlik >= 4 },
    burs_kesilir: ->(ogr) { ogr.aktif? && ogr.devamsizlik >= 3 }
  }.freeze

  def self.durum(ogr)
    KURALLAR.select { |_ad, kural| kural.call(ogr) }.keys
  end
end
