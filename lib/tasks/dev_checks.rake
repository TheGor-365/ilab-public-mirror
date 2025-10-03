# frozen_string_literal: true

# bin/rails dev:check_demo_data
namespace :dev do
  desc "Audit demo data: products, relations, indexes, sidebar view, sample queries"
  task check_demo_data: :environment do
    require "json"
    require "pp"

    c = ActiveRecord::Base.connection

    # ---------- helpers ----------
    def table_exists_pg?(c, name)
      !c.select_value("SELECT to_regclass(#{c.quote(name)})").nil?
    end

    def safe_count(c, table)
      c.select_value("SELECT COUNT(*)::bigint FROM #{table}") rescue nil
    end

    def section(title)  = puts "\n== #{title} =="
    def headline(title) = puts "\n— #{title}"
    def exists_index?(c, index_name) = !c.select_value("SELECT to_regclass(#{c.quote(index_name)})").nil?

    # ---------- counts ----------
    section "Counts"
    if table_exists_pg?(c, "products")
      puts "products: #{safe_count(c, "products")}"
    else
      abort "ERROR: таблица products отсутствует — сиды точно прогонялись?"
    end

    %w[repairs defects mods spare_parts].each do |t|
      next unless table_exists_pg?(c, t)
      puts "#{t}: #{safe_count(c, t)}"
    end

    %w[product_repairs product_defects product_mods product_spare_parts].each do |t|
      next unless table_exists_pg?(c, t)
      puts "#{t}: #{safe_count(c, t)}"
    end

    # ---------- relation density per product ----------
    jtables = %w[product_repairs product_defects product_mods product_spare_parts].select { |t| table_exists_pg?(c, t) }
    section "Relation density (min/avg/max per product)"
    jtables.each do |jt|
      stats = c.select_rows(<<~SQL).first rescue nil
        WITH x AS (
          SELECT product_id, COUNT(*) AS cnt FROM #{jt} GROUP BY product_id
        )
        SELECT COALESCE(MIN(cnt),0), COALESCE(ROUND(AVG(cnt),2),0), COALESCE(MAX(cnt),0) FROM x
      SQL
      if stats
        puts "#{jt.ljust(22)}  min=#{stats[0]}  avg=#{stats[1]}  max=#{stats[2]}"
      else
        puts "#{jt.ljust(22)}  n/a"
      end
    end

    # ---------- index checks ----------
    section "Index checks"

    expected_unique = {
      "phones_repairs"      => %w[phone_id repair_id],
      "defects_phones"      => %w[defect_id phone_id],
      "mods_repairs"        => %w[mod_id repair_id],
      "defects_mods"        => %w[defect_id mod_id],
      "defects_repairs"     => %w[defect_id repair_id],
      "product_repairs"     => %w[product_id repair_id],
      "product_defects"     => %w[product_id defect_id],
      "product_mods"        => %w[product_id mod_id],
      "product_spare_parts" => %w[product_id spare_part_id],
    }

    missing_unique_sql = []
    expected_unique.each do |t, cols|
      next unless table_exists_pg?(c, t)
      idx = "ux_#{t}_#{cols.join('_')}"
      if exists_index?(c, idx)
        puts "[OK] #{idx}"
      else
        puts "[MISSING] #{idx}"
        missing_unique_sql << "CREATE UNIQUE INDEX IF NOT EXISTS #{idx} ON #{t} (#{cols.join(', ')});"
      end
    end

    headline "btree indexes on product_id (for view filters)"
    expected_btree = {
      "product_repairs"     => "idx_product_repairs_product_id",
      "product_defects"     => "idx_product_defects_product_id",
      "product_mods"        => "idx_product_mods_product_id",
      "product_spare_parts" => "idx_product_spare_parts_product_id",
    }
    missing_btree_sql = []
    expected_btree.each do |t, idx|
      next unless table_exists_pg?(c, t)
      if exists_index?(c, idx)
        puts "[OK] #{idx}"
      else
        puts "[MISSING] #{idx}"
        missing_btree_sql << "CREATE INDEX IF NOT EXISTS #{idx} ON #{t} (product_id);"
      end
    end

    if missing_unique_sql.any? || missing_btree_sql.any?
      headline "Suggested SQL to add missing indexes"
      (missing_unique_sql + missing_btree_sql).each { |sql| puts sql }
    end

    # ---------- sidebar view presence ----------
    section "Sidebar view presence"
    is_mv  = c.select_value("SELECT EXISTS (SELECT 1 FROM pg_matviews WHERE matviewname='product_sidebar_entries')") rescue false
    is_vw  = c.select_value("SELECT EXISTS (SELECT 1 FROM pg_views    WHERE viewname   ='product_sidebar_entries')") rescue false
    label  = if is_mv == true || is_mv.to_s == "t" || is_mv.to_s == "true"
               "materialized view"
             elsif is_vw == true || is_vw.to_s == "t" || is_vw.to_s == "true"
               "plain view"
             else
               "absent"
             end
    puts "product_sidebar_entries: #{label}"

    # ---------- sample product deep check ----------
    section "Sample product deep check"
    pid = c.select_value("SELECT id FROM products ORDER BY RANDOM() LIMIT 1").to_i
    puts "Picked product_id=#{pid}"

    if defined?(Product)
      p = Product.where(id: pid).first
      if p
        puts "Product: #{p.try(:name) || p.try(:title) || p.id}"
        puts "  slug: #{p.try(:slug)}" if p.respond_to?(:slug)
        if p.respond_to?(:properties) && p.properties.present?
          puts "  properties keys: #{p.properties.keys.join(', ')}"
        end
        if p.respond_to?(:specs) && p.specs.present?
          puts "  specs keys: #{p.specs.keys.join(', ')}"
        end
      end
    end

    if label != "absent"
      headline "Counts from product_sidebar_entries"
      rows = c.select_rows(<<~SQL)
        SELECT kind, COUNT(*) FROM product_sidebar_entries
        WHERE product_id = #{pid}
        GROUP BY kind ORDER BY kind
      SQL
      rows.each { |k, cnt| puts "  #{k.ljust(11)}: #{cnt}" }

      headline "Top per kind (rn<=5)"
      top_sql = <<~SQL
        SELECT kind, entity_id, label
        FROM (
          SELECT *, ROW_NUMBER() OVER (PARTITION BY kind ORDER BY label) rn
          FROM product_sidebar_entries
          WHERE product_id = #{pid}
        ) t
        WHERE rn <= 5
        ORDER BY kind, label
      SQL
      c.select_rows(top_sql).each do |kind, eid, label_|
        puts "  #{kind.ljust(11)}  ##{eid}  #{label_}"
      end

      headline "Search smoke tests (ILIKE)"
      %w[display battery camera speaker frame].each do |q|
        pat = c.quote("%#{q}%")
        cnt = c.select_value(<<~SQL)
          SELECT COUNT(*) FROM product_sidebar_entries
          WHERE product_id = #{pid} AND label ILIKE #{pat}
        SQL
        puts "  q=#{q.ljust(8)} -> #{cnt} rows"
      end

      headline "EXPLAIN for search q='display' (trimmed)"
      begin
        pat = c.quote("%display%")
        plan = c.select_rows(<<~SQL)
          EXPLAIN SELECT kind, entity_id, label
          FROM product_sidebar_entries
          WHERE product_id = #{pid} AND label ILIKE #{pat}
          ORDER BY kind, label
          LIMIT 30
        SQL
        puts plan.flatten.join("\n")
      rescue => e
        puts "  (explain skipped: #{e.class}: #{e.message})"
      end
    else
      puts "  (view is absent — пропускаю проверки выборок по вьюхе)"
    end

    # ---------- JSON columns sample dump ----------
    if defined?(Product)
      section "JSON fields quick sample"
      json_cols = Product.columns.select { |col| [:json, :jsonb].include?(col.type) }.map(&:name)
      if json_cols.any?
        Product.order("RANDOM()").limit(3).each do |p|
          puts "Product##{p.id} #{p.try(:name) || p.try(:title)}"
          json_cols.each do |jc|
            val = p.public_send(jc)
            next if val.blank?
            short = val.is_a?(Hash) || val.is_a?(Array) ? JSON.pretty_generate(val)[0, 200] : val.to_s[0, 200]
            puts "  #{jc}: #{short}#{'…' if short.length == 200}"
          end
        end
      else
        puts "No JSON columns detected on products."
      end
    end

    puts "\n== Active products by family =="
    state_active =
      if Product.respond_to?(:states) && (Product.states.key?("active") || Product.states.key?(:active))
        Product.states["active"] || Product.states[:active]
      else
        col = Product.columns_hash["state"]
        col&.type == :integer ? 0 : "active"
      end
    rows = c.select_rows(<<~SQL) rescue []
      SELECT g.family, COUNT(*)::int
      FROM products p JOIN generations g ON g.id = p.generation_id
      WHERE p.state = #{c.quote(state_active)}
      GROUP BY g.family ORDER BY g.family
    SQL
    if rows.any?
      rows.each { |fam, cnt| puts "#{fam.ljust(14)} #{cnt}" }
    else
      puts "No active products per families (yet)"
    end

    puts "\n✔ Done."
  end
end
