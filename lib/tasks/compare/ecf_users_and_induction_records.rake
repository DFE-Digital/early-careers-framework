# frozen_string_literal: true

require "json-diff"

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

        puts "building detailed reports"

        users_with_no_ir_report = []
        ir_with_no_user_report = []
        diff_report = ""

        [*ids_from_serialized_users, *ids_from_serialized_induction_records].uniq.sort.each do |id|
          record_from_users_query = indexed_serialized_users[id]
          record_from_ir_query = indexed_serialized_induction_records[id]

          next if record_from_users_query == record_from_ir_query

          if record_from_users_query.blank?
            ir_with_no_user_report.add record_from_ir_query
          elsif record_from_ir_query.blank?
            users_with_no_ir_report.add record_from_users_query
          else
            diff_report += "####################\n"
            diff_report += "ID: #{id}\n"
            diff_report += JsonDiff.diff(record_from_users_query, record_from_ir_query, include_was: true).map { |el| "    #{el['path']}: \"#{el['was']}\"" }.join("\n")
            diff_report += "--------------------\n"
            diff_report += "#{JSON.pretty_generate(record_from_ir_query)}\n"
          end
        end

        puts "writing detailed reports to file"

        folder = Time.zone.now.strftime "%Y-%m-%dT%H-%M-%S"
        Dir.mkdir "/tmp/#{folder}/"
        File.open("/tmp/#{folder}/api_users_with_no_ir_report.json", "w") { |r| r.puts JSON.pretty_generate(users_with_no_ir_report) }
        File.open("/tmp/#{folder}/api_ir_with_no_user_report.json", "w") { |r| r.puts JSON.pretty_generate(ir_with_no_user_report) }
        File.open("/tmp/#{folder}/api_diff_report.json", "w") { |r| r.puts JSON.pretty_generate(diff_report) }
      end
    end
  end
end
