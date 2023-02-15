# frozen_string_literal: true

class Importers::ECFManualValidation < BaseService
  def call
    check_headers!

    rows.each do |row|
      participant_profile = get_profile(row["id"]) || next

      prepare_profile(participant_profile)

      Participants::ParticipantValidationForm.call(
        participant_profile,
        save_validation_data_without_match: true,
        data: {
          trn: row["trn"],
          nino: row["nino"],
          date_of_birth: safe_parse(row["dob"]),
          full_name: row["name"],
        },
      )

      if participant_profile.reload.ecf_participant_eligibility.nil?
        logger.warn "No match found #{row['id']}"
      elsif !participant_profile.eligible?
        logger.warn "#{participant_profile.ecf_participant_eligibility.reason} #{row['id']}"
      end
    end
  end

private

  attr_reader :path_to_csv, :logger

  def initialize(path_to_csv:, logger: Rails.logger)
    @path_to_csv = path_to_csv
    @logger = logger
  end

  def get_profile(id)
    user = Identity.find_user_by(id:)
    if user.nil?
      logger.warn "No profile found for #{id}. Skipping"
      return
    end

    ecf_profiles = user.teacher_profile.ecf_profiles

    if ecf_profiles.empty?
      logger.warn "No profile found for #{id}. Skipping"
      return
    elsif ecf_profiles.count > 1
      logger.warn "Multiple profiles found for #{id}. Skipping"
      return
    end

    ecf_profiles.first
  end

  def prepare_profile(participant_profile)
    # reset TRN if present on teacher profile to avoid "different trn" errors
    # unless already set via NPQ
    teacher_profile = participant_profile.teacher_profile
    if teacher_profile.trn.present? && teacher_profile.participant_profiles.npqs.none?
      teacher_profile.update!(trn: nil)
    end

    # remove any existing eligibilty
    participant_profile.ecf_participant_eligibility&.destroy!
  end

  def safe_parse(date)
    return if date.blank?

    Date.parse(date)
  rescue Date::Error
    logger.warn "Error parsing date"
    nil
  end

  def check_headers!
    unless %w[id name trn dob nino].all? { |header| rows.headers.include?(header) }
      raise NameError, "Invalid headers"
    end
  end

  def rows
    @rows ||= CSV.read(path_to_csv, headers: true)
  end
end
