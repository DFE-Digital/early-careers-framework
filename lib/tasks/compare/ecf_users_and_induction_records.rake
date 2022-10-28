# frozen_string_literal: true

namespace :compare do
  namespace :ecf_users_and_induction_records do
    desc "compare"
    task run: :environment do
      users = Api::V1::ECF::UsersQuery.new.all
      serialized_users = Api::V1::ECFUserSerializer.new(users).serializable_hash

      induction_records = Api::V1::ECF::InductionRecordsQuery.new.all
      serialized_induction_records = Api::V1::ECFInductionRecordSerializer.new(induction_records).serializable_hash

      blue_data = serialized_users[:data].map { |u| u[:id] }
      green_data = serialized_induction_records[:data].map { |u| u[:id] }

      duplicate_records = green_data.tally.filter { |_, v| v > 1 } # assuming we're counting the number of duplications rather than duplicated records
      same_records      = (blue_data & green_data)
      new_records       = green_data - same_records
      lost_records      = blue_data - same_records

      if new_records.count.zero? && lost_records.count.zero?
        puts "The API responses are the same"
      else
        puts "ERROR: The API responses are different"
        puts "Blue records: #{blue_data.count}"
        puts "Green records: #{green_data.count}"
        puts "Duplicates found: #{duplicate_records.count}"
        puts "Matches: #{same_records.count}"
        puts "Changed: #{(new_records - lost_records).count}"
        puts "New: #{(new_records - (new_records - lost_records)).count}"
        puts "Lost: #{(lost_records - (lost_records - new_records)).count}"

        new_records.each do |before|
          id = before[:id]
          after = lost_records.filter { |record| record[:id] == id }.first
          puts "\n\nExpected to find\n"
          puts JsonDiff.diff(before, after, include_was: true).map { |el| "    #{el['path']}: \"#{el['was']}\"" }.join("\n")
          puts "\nwithin:\n===\n#{JSON.pretty_generate(after)}"
        end
      end
    end
  end
end
