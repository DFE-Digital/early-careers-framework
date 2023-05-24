# frozen_string_literal: true

# noinspection RubyTooManyMethodsInspection, RubyTooManyInstanceVariablesInspection, RubyInstanceMethodNamingConvention
class DetermineTrainingRecordState < BaseService
  def call
    @participant_profile.training_record_states.latest_for(participant_profile: @participant_profile, induction_record: @induction_record, delivery_partner: @delivery_partner, appropriate_body: @appropriate_body, school: @school)
  end

  def is_record_state?(state)
    call.record_state == state
  end

private

  def initialize(participant_profile:, induction_record: nil, delivery_partner: nil, appropriate_body: nil, school: nil)
    unless participant_profile.is_a? ParticipantProfile
      raise ArgumentError, "Expected a ParticipantProfile, got #{participant_profile.class}"
    end

    @participant_profile = participant_profile

    if participant_profile.ecf?
      unless induction_record.nil? || induction_record.is_a?(InductionRecord)
        raise ArgumentError, "Expected an InductionRecord, got #{induction_record.class}"
      end

      unless delivery_partner.nil? || delivery_partner.is_a?(DeliveryPartner)
        raise ArgumentError, "Expected a DeliveryPartner, got #{delivery_partner.class}"
      end

      unless appropriate_body.nil? || appropriate_body.is_a?(AppropriateBody)
        raise ArgumentError, "Expected a AppropriateBody, got #{appropriate_body.class}"
      end

      unless school.nil? || school.is_a?(School)
        raise ArgumentError, "Expected a School, got #{school.class}"
      end
    end

    @induction_record = induction_record
    @delivery_partner = delivery_partner
    @appropriate_body = appropriate_body
    @school = school
  end
end
