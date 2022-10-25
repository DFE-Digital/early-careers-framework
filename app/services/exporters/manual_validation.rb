# frozen_string_literal: true

# rubocop:disable Rails/Output
class Exporters::ManualValidation < BaseService
  def call
    puts "id,email,type,full_name,date_of_birth,trn,nino"

    # participants at manual_check status
    query = ParticipantProfile::ECF
      .active_record
      .joins(:ecf_participant_eligibility)
      .includes(:ecf_participant_validation_data, participant_identity: :user)
      .where(ecf_participant_eligibility: { status: "manual_check" })

    query = query.where(ecf_participant_eligibility: { qts: true }) if only_with_qts

    query = query.where.not(ecf_participant_eligibility: { reason: "no_induction" }) unless include_no_induction

    output_participant_data(query)

    # participants that entered validation data but were not matched with DQT
    if include_not_matched
      query = ParticipantProfile::ECF
        .active_record
        .joins(:ecf_participant_validation_data)
        .left_joins(:ecf_participant_eligibility)
        .includes(participant_identity: :user)
        .where(ecf_participant_eligibility: { id: nil })

      output_participant_data(query)
    end
  end

private

  attr_reader :only_with_qts, :include_not_matched, :include_no_induction

  def initialize(only_with_qts: true, include_not_matched: true, include_no_induction: false)
    @only_with_qts = only_with_qts
    @include_not_matched = include_not_matched
    @include_no_induction = include_no_induction
  end

  def output_participant_data(query)
    query.find_each do |profile|
      puts [profile.participant_identity.user.id,
            profile.participant_identity.user.email,
            profile.type,
            profile.ecf_participant_validation_data&.full_name,
            profile.ecf_participant_validation_data&.date_of_birth,
            profile.ecf_participant_validation_data&.trn,
            profile.ecf_participant_validation_data&.nino].join(",")
    end
  end
end
# rubocop:enable Rails/Output
