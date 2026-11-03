class Ogrenci
  DURUMLAR = %i[aktif donduruldu mezun].freeze
  DEVAMSIZLIK_ARALIGI = (0..10)

  attr_reader :ad, :durum, :devamsizlik

  def initialize(ad:, durum: :aktif, devamsizlik: 0)
    unless DURUMLAR.include?(durum)
      raise ArgumentError, "geçersiz durum: #{durum.inspect} (#{DURUMLAR.join(', ')} olmalı)"
    end
    unless devamsizlik.is_a?(Integer) && DEVAMSIZLIK_ARALIGI.cover?(devamsizlik)
      raise ArgumentError, "devamsizlik #{DEVAMSIZLIK_ARALIGI} arasında tam sayı olmalı: #{devamsizlik.inspect}"
    end

    @ad = ad
    @durum = durum
    @devamsizlik = devamsizlik
  end

  DURUMLAR.each do |d|
    define_method(:"#{d}?") { durum == d }
  end
end
