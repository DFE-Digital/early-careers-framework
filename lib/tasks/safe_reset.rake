# frozen_string_literal: true

namespace :db do
  desc "Drop, create, migrate then seed the development database"
  task safe_reset: :environment do
    if Rails.env.development? || Rails.env.deployed_development?
      Rake::Task["db:reset"].invoke
      puts "Reseeded the database!"
    else
      puts "You should think twice before recreating staging or production database!"
      puts "Use 'db:reset' task to do it if you really want to."
    end
  end
end
