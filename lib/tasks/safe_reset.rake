# frozen_string_literal: true

namespace :db do
  desc "Drop, create, migrate then seed the development database"
  task safe_reset: :environment do
    if Rails.env.development? || Rails.env.deployed_development?
      connection = ActiveRecord::Base.connection
      tables = connection
                   .execute("SELECT * FROM pg_catalog.pg_tables;")
                   .filter { |row| row["schemaname"].include?("public") }
                   .map { |row| row["tablename"] }
      tables.delete "schema_migrations"
      tables.each { |table| connection.execute("TRUNCATE #{table} CASCADE;") }
      Rake::Task["db:seed"].invoke
      puts "Re-seeded the database!"
    else
      puts "You should think twice before recreating staging or production database!"
      puts "Use 'db:reset' task to do it if you really want to."
    end
  end
end
