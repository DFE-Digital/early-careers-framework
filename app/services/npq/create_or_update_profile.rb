# frozen_string_literal: true

module NPQ
  class CreateOrUpdateProfile
    attr_reader :npq_validation_data

    def initialize(npq_validation_data:)
      @npq_validation_data = npq_validation_data
    end

    def call
      if npq_validation_data.teacher_reference_number_verified?
        teacher_profile.trn = npq_validation_data.teacher_reference_number
      end

      teacher_profile.save!

      participant_profile.schedule ||= schedule
      participant_profile.npq_course ||= npq_validation_data.npq_course
      participant_profile.teacher_profile = teacher_profile
      participant_profile.user = user
      participant_profile.school_urn = npq_validation_data.school_urn
      participant_profile.school_ukprn = npq_validation_data.school_ukprn
      participant_profile.save!

      ParticipantProfileState.find_or_create_by!(participant_profile: participant_profile)
    end

  private

    def participant_profile
      @participant_profile ||= ParticipantProfile::NPQ.find_or_initialize_by(id: npq_validation_data.id)
    end

    def teacher_profile
      @teacher_profile ||= user.teacher_profile || user.build_teacher_profile
    end

    def user
      @user ||= npq_validation_data.user
    end

    def schedule
      case npq_validation_data.npq_course.identifier
      when "npq-leading-teaching", "npq-leading-behaviour-culture", "npq-leading-teaching-development"
        Finance::Schedule.default_npq_leadership
      when "npq-senior-leadership", "npq-headship", "npq-executive-leadership"
        Finance::Schedule.default_npq_specialist
      else
        raise ArgumentError "Invalid course identifier"
      end
    end
  end
end
