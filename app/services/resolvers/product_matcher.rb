# frozen_string_literal: true
module Resolvers
  class ProductMatcher
    Result = Struct.new(:model, :phone, :generation, keyword_init: true)

    def self.call(product)
      title = (product.respond_to?(:match_title_for_catalog) ? product.match_title_for_catalog : product.name).to_s
      return Result.new unless title.present?

      norm = Normalizers::AppleTitleNormalizer.call(title)
      candidates = build_candidates(norm, family_hint: product.category&.try(:heading))

      gen   = find_generation(candidates)
      phone = product.phone || find_phone(candidates)
      model = find_model(candidates)

      gen   ||= phone&.respond_to?(:generation) ? phone.generation : nil
      phone ||= gen&.respond_to?(:phone) ? gen.phone : phone
      model ||= gen&.respond_to?(:model) ? gen.model : model
      model ||= phone&.respond_to?(:model) ? phone.model : model

      Result.new(model: model, phone: phone, generation: gen)
    end

    class << self
      def build_candidates(norm, family_hint: nil)
        fam = family_hint.to_s.downcase.presence || norm.tokens.first
        num = norm.tokens.find { |t| t =~ /^\d{1,2}$/ }
        suffixes = norm.tokens & %w[pro max plus mini air ultra se]

        arr = []
        arr << norm.base_label
        arr << [fam, num, *suffixes].compact.join(" ").squeeze(" ").strip if fam || num
        arr << [fam, num, "pro max"].compact.join(" ").strip if fam && num
        arr << [fam, num, "pro"].compact.join(" ").strip     if fam && num
        arr << [fam, num, "plus"].compact.join(" ").strip    if fam && num
        arr << [fam, num, "mini"].compact.join(" ").strip    if fam && num
        arr << [fam, num].compact.join(" ").strip            if fam && num
        arr.map { |s| s.gsub(/\s+/, " ").strip }.uniq.reject(&:blank?)
      end

      def find_generation(cands)
        return nil unless defined?(Generation) && Generation.table_exists?
        cols = %w[title name code] & Generation.column_names
        # 1) точное равенство
        cands.each do |label|
          cols.each { |col| (gen = Generation.find_by("LOWER(#{col}) = ?", label.downcase)) and return gen }
        end
        # 2) ILIKE
        cands.each do |label|
          cols.each { |col| (gen = Generation.where("#{col} ILIKE ?", "%#{Search::FuzzyLookup.sanitize_like(label)}%").order(:id).first) and return gen }
        end
        # 3) фуззи
        Search::FuzzyLookup.best_match(Generation, cols, cands.first)
      end

      def find_phone(cands)
        return nil unless defined?(Phone) && Phone.table_exists?
        cols = %w[model_title title name] & Phone.column_names
        cands.each do |label|
          cols.each { |col| (ph = Phone.find_by("LOWER(#{col}) = ?", label.downcase)) and return ph }
        end
        cands.each do |label|
          cols.each { |col| (ph = Phone.where("#{col} ILIKE ?", "%#{Search::FuzzyLookup.sanitize_like(label)}%").order(:id).first) and return ph }
        end
        Search::FuzzyLookup.best_match(Phone, cols, cands.first)
      end

      def find_model(cands)
        return nil unless defined?(Model) && Model.table_exists? && Model.column_names.include?("title")
        cands.each do |label|
          (m = Model.find_by("LOWER(title) = ?", label.downcase)) and return m
        end
        cands.each do |label|
          (m = Model.where("title ILIKE ?", "%#{Search::FuzzyLookup.sanitize_like(label)}%").order(:id).first) and return m
        end
        Search::FuzzyLookup.best_match(Model, %w[title], cands.first)
      end
    end
  end
end
