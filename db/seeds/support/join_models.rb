# db/seeds/support/join_models.rb
# Лёгкие AR-классы для join-таблиц, чтобы использовать insert_all/upsert_all
class DefectsMod   < ApplicationRecord; self.table_name = 'defects_mods';   end
class DefectsPhone < ApplicationRecord; self.table_name = 'defects_phones'; end
class ModsRepair   < ApplicationRecord; self.table_name = 'mods_repairs';   end
class PhonesRepair < ApplicationRecord; self.table_name = 'phones_repairs'; end
class DefectsRepair< ApplicationRecord; self.table_name = 'defects_repairs';end
