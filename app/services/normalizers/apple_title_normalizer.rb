# frozen_string_literal: true

require "ostruct"

module Normalizers
  class AppleTitleNormalizer
    COLOR_WORDS = %w[
      black white blue green red pink purple yellow orange silver gold
      graphite gray grey space midnight starlight titanium natural
      белый черный чёрный синий голубой зеленый зелёный красный розовый
      жёлтый желтый фиолетовый серый графитовый серебристый золотой
      титан натурал натуральный
    ].freeze

    FAMILY_WORDS = %w[iphone ipad ipod macbook imac mac mini watch airpods apple].freeze
    SUFFIXES     = %w[pro max plus mini air ultra se].freeze

    STORAGE_RE = /\b(\d+)\s*(gb|tb|гб|тб)\b/i
    JUNK_RE    = /\b(б\/у|бу|used|refurbished|for parts|parts|для\s+запчастей|сертифицированный|сертиф)\b/i

    def self.call(title)
      raw = title.to_s.dup

      storage_gb = nil
      raw.gsub!(STORAGE_RE) { storage_gb = Regexp.last_match(1).to_i; "" }
      raw.gsub!(JUNK_RE, "")

      words = raw.downcase.scan(/[[:alnum:]\-]+/)

      color = nil
      words.reject! { |w| color = w if COLOR_WORDS.include?(w) }

      # «iPhone Model 1» → family=iphone, num=1
      family   = words.find { |w| FAMILY_WORDS.include?(w) }
      number   = words.find { |w| w =~ /^\d{1,2}$/ } # 4..15
      suffixes = words.select { |w| SUFFIXES.include?(w) }

      # базовая форма: "iphone 15 pro max" / "ipad 9"
      base = [family || words.first, number, *suffixes].compact.join(" ").squeeze(" ").strip
      OpenStruct.new(base_label: base, tokens: base.split, storage_gb: storage_gb, color: color)
    end
  end
end
