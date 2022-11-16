# frozen_string_literal: true

require "json-diff"

namespace :compare do
  namespace :ecf_users_and_induction_records do
    desc "compare"
    task run: :environment do
      puts "getting user data..."
      users = Api::V1::ECF::UsersQuery.new.all
      serialized_users = Api::V1::ECFUserSerializer.new(users).serializable_hash

      puts "getting IR data..."
      induction_records = Api::V1::ECF::InductionRecordsQuery.new.all
      serialized_induction_records = Api::V1::ECFInductionRecordSerializer.new(induction_records).serializable_hash

      puts "getting mapping data..."
      ui_to_ei_map = ParticipantIdentity.select("participant_identities.user_id AS id, participant_identities.external_identifier AS external_identifier").to_a.map(&:serializable_hash)

      puts "analysing..."

      if serialized_users.count.zero? && serialized_induction_records.count.zero?
        puts "The API responses are both empty!"
      else
        indexed_serialized_users = serialized_users[:data].index_by { |x| x[:id] }
        indexed_serialized_induction_records = serialized_induction_records[:data].index_by { |x| x[:id] }

        users_with_no_ir_report = []
        ir_with_no_user_report = []
        diff_report = []

        ui_to_ei_map.each do |records|
          record_from_users_query = indexed_serialized_users[records["id"]]
          record_from_ir_query = indexed_serialized_induction_records[records["external_identifier"]]

          if record_from_users_query.blank? && record_from_ir_query.blank?
            # skip if both are not found - do we care about these ?
            next
          elsif record_from_users_query.blank?
            ir_with_no_user_report.push user_id: records["id"], induction_record: record_from_ir_query
          elsif record_from_ir_query.blank?
            users_with_no_ir_report.push external_identifier: records["external_identifier"], user_record: record_from_users_query
          elsif record_from_users_query[:attributes] == record_from_ir_query[:attributes]
            # skip if the attributes are the same
            next
          else
            original_attributes = {}
            JsonDiff.diff(record_from_users_query[:attributes], record_from_ir_query[:attributes], include_was: true).each do |el|
              original_attributes[el["path"].sub("/", "")] = el["was"]
            end

            diff_report.push user_id: records["id"],
                             external_identifier: records["external_identifier"],
                             old_record: { attributes: original_attributes },
                             new_record: record_from_ir_query
          end
        end

        puts "Records returned by the users query:            #{serialized_users[:data].count}"
        puts "Records returned by the induction record query: #{serialized_induction_records[:data].count}"
        puts "Records found in users query but not in IR:     #{users_with_no_ir_report.count}"
        puts "Records found in IR query but not in users:     #{ir_with_no_user_report.count}"
        puts "Records with differences:                       #{diff_report.count}"
        puts ""
        puts "building detailed reports..."

        folder_timestamp = Time.zone.now.strftime "%Y-%m-%dT%H-%M-%S"
        folder_path = "/tmp/#{folder_timestamp}"

        puts "writing detailed reports to folder #{folder_path}/"

        Dir.mkdir folder_path
        File.open("#{folder_path}/api_users_with_no_ir_report.json", "w") { |r| r.puts JSON.pretty_generate(users_with_no_ir_report) }
        File.open("#{folder_path}/api_ir_with_no_user_report.json", "w") { |r| r.puts JSON.pretty_generate(ir_with_no_user_report) }
        File.open("#{folder_path}/api_diff_report.json", "w") { |r| r.puts JSON.pretty_generate(diff_report) }
      end
    end
  end
end
