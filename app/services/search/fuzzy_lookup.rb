# frozen_string_literal: true
module Search
  class FuzzyLookup
    def self.pg?
      ActiveRecord::Base.connection.adapter_name.downcase.include?("postgres")
    end

    def self.similarity_supported?
      pg? && ActiveRecord::Base.connection.select_value("SELECT EXISTS (SELECT 1 FROM pg_extension WHERE extname='pg_trgm')").to_s == "t"
    rescue
      false
    end

    def self.best_match(klass, attrs, label, min_score: 0.35)
      return nil if label.blank?
      label = label.to_s.strip

      if similarity_supported?
        # выбираем лучший атрибут по similarity
        attrs.each do |attr|
          next unless klass.column_names.include?(attr.to_s)
          sql = <<~SQL
            SELECT #{klass.table_name}.*
            FROM #{klass.table_name}
            ORDER BY similarity(LOWER(#{attr}), LOWER(?)) DESC
            LIMIT 1
          SQL
          rec = klass.find_by_sql([sql, label]).first
          score = rec ? score_for(klass, attr, rec, label) : 0.0
          return rec if score >= min_score
        end
        nil
      else
        # fallback: ILIKE
        attrs.each do |attr|
          next unless klass.column_names.include?(attr.to_s)
          rec = klass.find_by("LOWER(#{attr}) = ?", label.downcase) ||
                klass.where("#{attr} ILIKE ?", "%#{sanitize_like(label)}%").order(:id).first
          return rec if rec
        end
        nil
      end
    end

    def self.score_for(klass, attr, rec, label)
      return 0.0 unless rec && rec.respond_to?(attr)
      a = rec.public_send(attr).to_s.downcase
      b = label.to_s.downcase
      # локальная грубая оценка схожести
      lcs = longest_common_subsequence(a, b).to_f
      (2.0 * lcs) / (a.size + b.size)
    rescue
      0.0
    end

    def self.longest_common_subsequence(a, b)
      m = Array.new(a.length + 1) { Array.new(b.length + 1, 0) }
      (1..a.length).each do |i|
        (1..b.length).each do |j|
          m[i][j] = if a[i - 1] == b[j - 1]
            m[i - 1][j - 1] + 1
          else
            [m[i - 1][j], m[i][j - 1]].max
          end
        end
      end
      m[a.length][b.length]
    end

    def self.sanitize_like(str)
      ActiveRecord::Base.sanitize_sql_like(str.to_s)
    end
  end
end
