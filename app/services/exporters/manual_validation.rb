# frozen_string_literal: true

class Exporters::ManualValidation < BaseService
  def call
    Rails.logger.info "id,email,type,full_name,date_of_birth,trn,nino"

    # participants at manual_check status
    query = TeacherProfile
      .joins(current_ecf_profile: :ecf_participant_eligibility)
      .includes(:user, current_ecf_profile: :ecf_participant_validation_data)
      .where(ecf_participant_eligibility: { status: "manual_check" })

    query = query.where(ecf_participant_eligibility: { qts: true }) if only_with_qts

    output_participant_data(query)

    # participants that entered validation data but were not matched with DQT
    if include_not_matched
      query = TeacherProfile
        .joins(current_ecf_profile: :ecf_participant_validation_data)
        .left_joins(current_ecf_profile: :ecf_participant_eligibility)
        .includes(:user)
        .where(ecf_participant_eligibility: { id: nil })

      output_participant_data(query)
    end
  end

private

  attr_reader :only_with_qts, :include_not_matched

  def initialize(only_with_qts: true, include_not_matched: true)
    @only_with_qts = only_with_qts
    @include_not_matched = include_not_matched
  end

  def output_participant_data(query)
    query.find_each do |teacher_profile|
      Rails.logger.info [teacher_profile.user.id,
                         teacher_profile.user.email,
                         teacher_profile.current_ecf_profile.type,
                         teacher_profile.current_ecf_profile.ecf_participant_validation_data.full_name,
                         teacher_profile.current_ecf_profile.ecf_participant_validation_data.date_of_birth,
                         teacher_profile.current_ecf_profile.ecf_participant_validation_data.trn,
                         teacher_profile.current_ecf_profile.ecf_participant_validation_data.nino].join(",")
    end
  end
end
