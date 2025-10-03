# bin/rails app:prime
# PER=10 SCOPE=all bin/rails ilab:catalog:ensure_min_products_env

namespace :app do
  desc "Migrate and seed everything (one command)"
  task prime: ["db:migrate", "db:seed"]
end
