# frozen_string_literal: true

Faker::Config.locale = "en-GB"
desc "Anonymise and dump data for seeds"

def dump_to_csv(filename, headers:, rows:, ext: ".csv", write_headers: true)
  path = Rails.root.join("db/seeds/anonymous_seed_generator", filename + ext)

  CSV.open(path, "wb", headers:, write_headers:) { |csv| rows.each { |row| csv << row } }
end

def print_status(status, count, &block)
  print "#{status} (#{count})".ljust(78)
  block.call
  puts "✅"
end

namespace(:anonymous_seed_generator) do
  desc "Dump all data to new seed files"
  task(
    dump_all: %i[
      environment
      dump_cohorts
      dump_schools
      dump_partnerships
    ],
  )
end
