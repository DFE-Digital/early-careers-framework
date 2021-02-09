# frozen_string_literal: true

desc "Lint ruby code"
namespace :lint do
  desc "Lint ruby code"
  task ruby: :environment do
    puts "Linting ruby..."
    system "bundle exec rubocop"
  end

  desc "Lint scss"
  task scss: :environment do
    puts "Linting scss..."
    system "bundle exec scss-lint app/webpacker/styles"
  end
end
