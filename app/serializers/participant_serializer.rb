# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"

class ParticipantSerializer
  include JSONAPI::Serializer
  include JSONAPI::Serializer::Instrumentation

  class << self
    def active_participant_attribute(attr, &blk)
      attribute attr do |user|
        blk.call(user) if participant_active?(user)
      end
    end

    def participant_active?(user)
      user.teacher_profile.ecf_profile_2021&.active_record?
    end

    def trn(user)
      user.teacher_profile.trn || user.teacher_profile.ecf_profile_2021.ecf_participant_validation_data&.trn
    end

    def validated_trn(user)
      eligibility_status = user.teacher_profile.ecf_profile_2021.ecf_participant_eligibility&.status
      if %w[matched eligible].include?(eligibility_status)
        user.teacher_profile.trn
      end
    end

    def eligible_for_funding?(user)
      ecf_participant_eligibility = user.teacher_profile.ecf_profile_2021.ecf_participant_eligibility
      return if ecf_participant_eligibility.nil?
      return true if ecf_participant_eligibility.eligible_status?
      return false if ecf_participant_eligibility.ineligible_status?
    end
  end

  set_id :id
  active_participant_attribute :email, &:email

  active_participant_attribute :full_name, &:full_name

  active_participant_attribute :mentor_id do |user|
    user.teacher_profile.early_career_teacher_profile&.mentor&.id
  end

  active_participant_attribute :school_urn do |user|
    user.teacher_profile.ecf_profile_2021&.school&.urn
  end

  active_participant_attribute :participant_type do |user|
    case user.teacher_profile.ecf_profile_2021.type
    when ParticipantProfile::ECT.name
      :ect
    when ParticipantProfile::Mentor.name
      :mentor
    end
  end

  active_participant_attribute :cohort do |user|
    user.teacher_profile.ecf_profile_2021.cohort.start_year.to_s
  end

  attribute :status do |user|
    user.teacher_profile.ecf_profile_2021&.status || "withdrawn"
  end

  active_participant_attribute :teacher_reference_number do |user|
    trn(user)
  end

  active_participant_attribute :teacher_reference_number_validated do |user|
    trn(user).nil? ? nil : validated_trn(user).present?
  end

  active_participant_attribute :eligible_for_funding do |user|
    # TODO: we want to check eligibility without communicating it yet - except for sandbox
    if Rails.env.sandbox? || FeatureFlag.active?(:eligibility_notifications)
      eligible_for_funding?(user)
    end
  end

  active_participant_attribute :pupil_premium_uplift do |user|
    user.teacher_profile.ecf_profile_2021&.pupil_premium_uplift
  end

  active_participant_attribute :sparsity_uplift do |user|
    user.teacher_profile.ecf_profile_2021&.sparsity_uplift
  end

  active_participant_attribute :training_status do |user|
    user.teacher_profile.ecf_profile_2021&.training_status || "active"
  end

  active_participant_attribute :schedule_identifier do |user|
    user.teacher_profile.ecf_profile_2021&.schedule&.schedule_identifier
  end
end
