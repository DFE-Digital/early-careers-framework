# frozen_string_literal: true

class Importers::ECFManualValidation < BaseService
  def call
    check_headers

    rows.each do |row|
      user = Identity.find_user_by(id: row["id"])

      if user.nil?
        puts "No profile found for #{row['id']}. Skipping"
        next
      end

      participant_profile = user.teacher_profile.current_ecf_profile
      if participant_profile.nil?
        puts "No profile found for #{row['id']}. Skipping"
        next
      end

      Participants::ParticipantValidationForm.call(
        participant_profile,
        save_validation_data_without_match: false,
        data: {
          trn: row["trn"],
          nino: row["nino"],
          dob: Date.parse(row["dob"]),
          full_name: row["name"],
        },
      )

      if participant_profile.ecf_participant_eligibility.nil?
        puts "No match found #{row['id']}"
        next
      end

      unless participant_profile.ecf_participant_eligibility.eligible_status?
        puts "#{participant_profile.ecf_participant_eligibility.reason} #{row['id']}"
      end
    end
  end

private

  attr_reader :path_to_csv

  def initialize(path_to_csv:)
    @path_to_csv = path_to_csv
  end

  def check_headers
    unless %w[id name trn dob nino].all? { |header| rows.headers.include?(header) }
      raise NameError, "Invalid headers"
    end
  end

  def rows
    @rows ||= CSV.read(path_to_csv, headers: true)
  end
end
