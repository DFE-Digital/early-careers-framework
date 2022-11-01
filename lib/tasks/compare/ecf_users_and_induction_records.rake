# frozen_string_literal: true

namespace :compare do
  namespace :ecf_users_and_induction_records do
    desc "compare"
    task run: :environment do
      users = Api::V1::ECF::UsersQuery.new.all
      serialized_users = Api::V1::ECFUserSerializer.new(users).serializable_hash

      induction_records = Api::V1::ECF::InductionRecordsQuery.new.all
      serialized_induction_records = Api::V1::ECFInductionRecordSerializer.new(induction_records).serializable_hash

      ids_from_serialized_users = serialized_users[:data].map { |u| u[:id] }
      ids_from_serialized_induction_records = serialized_induction_records[:data].map { |u| u[:id] }

      duplicate_records = ids_from_serialized_induction_records.tally.filter { |_, v| v > 1 } # assuming we're counting the number of duplications rather than duplicated records
      same_records      = (ids_from_serialized_users & ids_from_serialized_induction_records)
      ir_but_not_users  = ids_from_serialized_induction_records - ids_from_serialized_users
      users_but_not_ir  = ids_from_serialized_users - ids_from_serialized_induction_records

      if ids_from_serialized_users.count.zero? && ids_from_serialized_induction_records.count.zero?
        puts "The API responses are both empty"
      else
        puts "ERROR: The API responses are different"

        puts "Records returned by the users query:            #{ids_from_serialized_users.count}"
        puts "Records returned by the induction record query: #{ids_from_serialized_induction_records.count}"
        puts "Duplicates found in induction record query:     #{duplicate_records.count}"
        puts "Records found in both queries:                  #{same_records.count}"
        puts "Records found users query but not IR:           #{users_but_not_ir.count}"
        puts "Records found IR query but not users:           #{ir_but_not_users.count}"

        indexed_serialized_users = serialized_users[:data].index_by { |x| x[:id] }
        indexed_serialized_induction_records = serialized_induction_records[:data].index_by { |x| x[:id] }

        filename = "/tmp/ecf_users_and_induction_records-#{SecureRandom.hex}.txt"

        puts "writing detailed report to file '#{filename}'"

        File.open(filename, "w") do |r|
          [*ids_from_serialized_users, *ids_from_serialized_induction_records].uniq.sort.each do |id|
            record_from_users_query = indexed_serialized_users[id]
            record_from_ir_query = indexed_serialized_induction_records[id]

            next if record_from_users_query == record_from_ir_query

            r.puts "####################"
            r.puts "ID: #{id}"

            if record_from_users_query.blank?
              r.puts "record_from_users_query is empty"
            elsif record_from_ir_query.blank?
              r.puts "record_from_ir_query is empty"
            else
              r.puts "Difference detected"
              r.puts JsonDiff.diff(record_from_users_query, record_from_ir_query, include_was: true).map { |el| "    #{el['path']}: \"#{el['was']}\"" }.join("\n")
              r.puts "\nwithin:\n===\n#{JSON.pretty_generate(record_from_ir_query)}"
            end
          end
        end
      end
    end
  end
end
