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

      puts "analysing..."
      if serialized_users.count.zero? && serialized_induction_records.count.zero?
        puts "The API responses are both empty!"
      else
        indexed_serialized_users = serialized_users[:data].index_by { |x| x[:id] }
        indexed_serialized_induction_records = serialized_induction_records[:data].index_by { |x| x[:id] }

        ids_from_serialized_users = serialized_users[:data].map { |u| u[:id] }
        ids_from_serialized_induction_records = serialized_induction_records[:data].map { |u| u[:id] }

        users_with_no_ir_report = []
        ir_with_no_user_report = []
        diff_report = []

        [*ids_from_serialized_users, *ids_from_serialized_induction_records].uniq.sort.each do |id|
          record_from_users_query = indexed_serialized_users[id]
          record_from_ir_query = indexed_serialized_induction_records[id]

          if record_from_users_query.blank?
            ir_with_no_user_report.push record_from_ir_query
          elsif record_from_ir_query.blank?
            users_with_no_ir_report.push record_from_users_query
          elsif record_from_users_query[:attributes] == record_from_ir_query[:attributes]
            # skip if the attributes are the same
            next
          else
            original_attributes = {}
            JsonDiff.diff(record_from_users_query[:attributes], record_from_ir_query[:attributes], include_was: true).each do |el|
              original_attributes[el["path"].sub("/", "")] = el["was"]
            end

            diff_report.push old_record: { attributes: original_attributes },
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

        anon_serialized_users = serialized_users[:data].map do |record|
          record[:attributes][:full_name] = "anon"
          record[:attributes][:email] = "example@example.com"
          record
        end
        anon_serialized_users = anon_serialized_users.sort_by { |record| record[:id] }

        anon_serialized_induction_records = serialized_induction_records[:data].map do |record|
          record[:attributes][:full_name] = "anon"
          record[:attributes][:email] = "example@example.com"
          record
        end
        anon_serialized_induction_records = anon_serialized_induction_records.sort_by { |record| record[:id] }

        anon_users_with_no_ir_report = users_with_no_ir_report.map do |record|
          record[:attributes][:full_name] = "anon"
          record[:attributes][:email] = "example@example.com"
          record
        end

        anon_ir_with_no_user_report = ir_with_no_user_report.map do |record|
          record[:attributes][:full_name] = "anon"
          record[:attributes][:email] = "example@example.com"
          record
        end

        anon_diff_report = diff_report.map do |record|
          record[:old_record][:attributes][:full_name] = "anon" unless record[:old_record][:attributes][:full_name] == nil
          record[:old_record][:attributes][:email] = "example@example.com" unless record[:old_record][:attributes][:email] == nil
          record[:new_record][:attributes][:full_name] = "anon"
          record[:new_record][:attributes][:email] = "example@example.com"
          record
        end

        folder_timestamp = Time.zone.now.strftime "%Y-%m-%dT%H-%M-%S"
        folder_path = "/tmp/#{folder_timestamp}"

        puts "writing detailed reports to folder #{folder_path}/"

        Dir.mkdir folder_path
        File.open("#{folder_path}/api_anon_users_response.json", "w") { |r| r.puts JSON.pretty_generate(anon_serialized_users) }
        File.open("#{folder_path}/api_anon_ir_response.json", "w") { |r| r.puts JSON.pretty_generate(anon_serialized_induction_records) }
        File.open("#{folder_path}/api_users_with_no_ir_report.json", "w") { |r| r.puts JSON.pretty_generate(anon_users_with_no_ir_report) }
        File.open("#{folder_path}/api_ir_with_no_user_report.json", "w") { |r| r.puts JSON.pretty_generate(anon_ir_with_no_user_report) }
        File.open("#{folder_path}/api_diff_report.json", "w") { |r| r.puts JSON.pretty_generate(anon_diff_report) }
      end
    end
  end
end
