# frozen_string_literal: true

namespace :db do
  desc "Remove all database content, then seed it. Only for dev environments."
  task safe_reset: :environment do
    if Rails.env.development? || Rails.env.deployed_development?
      connection = ActiveRecord::Base.connection
      tables = connection
                   .execute("SELECT * FROM pg_catalog.pg_tables;")
                   .filter { |row| row["schemaname"].include?("public") }
                   .map { |row| row["tablename"] }
      tables.delete "schema_migrations"
      tables.delete "spatial_ref_sys"
      tables.each { |table| connection.execute("TRUNCATE #{table} CASCADE;") }
      Rake::Task["db:seed"].invoke
      puts "Re-seeded the database!"
    else
      puts "You should think twice before recreating staging or production database!"
      puts "Fire off Rails console and copy the code from this task if you really have to."
      puts "Make sure you know what you are doing and maybe do a back-up first."
    end
  end
end
