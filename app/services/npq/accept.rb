# frozen_string_literal: true

module NPQ
  class Accept
    class << self
      def call(npq_application:)
        new(npq_application: npq_application).call
      end
    end

    attr_reader :npq_application

    def initialize(npq_application:)
      @npq_application = npq_application
    end

    def call
      if npq_application.accepted?
        npq_application.errors.add(:lead_provider_approval_status, :has_already_been_accepted)
        return false
      end

      if has_other_accepted_applications_with_same_course?
        npq_application.errors.add(:lead_provider_approval_status, :has_another_accepted_application)
        return false
      end

      ApplicationRecord.transaction do
        teacher_profile.update!(trn: npq_application.teacher_reference_number) if npq_application.teacher_reference_number_verified?
        create_profile
        npq_application.update(lead_provider_approval_status: "accepted") && other_applications.update(lead_provider_approval_status: "rejected")
      end
    end

  private

    def has_other_accepted_applications_with_same_course?
      NPQApplication.where(user_id: user.id)
        .where(npq_course: npq_course)
        .where(lead_provider_approval_status: "accepted")
        .where.not(id: npq_application.id)
        .exists?
    end

    def other_applications
      @other_applications ||= NPQApplication.where(user_id: user.id)
                                               .where(npq_course: npq_course)
                                               .where.not(id: npq_application.id)
    end

    def create_profile
      ParticipantProfile::NPQ.create!(
        id: npq_application.id,
        schedule: schedule,
        npq_course: npq_application.npq_course,
        teacher_profile: teacher_profile,
        school_urn: npq_application.school_urn,
        school_ukprn: npq_application.school_ukprn,
      ) do |participant_profile|
        ParticipantProfileState.find_or_create_by(participant_profile: participant_profile)
      end
    end

    def teacher_profile
      @teacher_profile ||= user.teacher_profile || user.build_teacher_profile
    end

    def user
      @user ||= npq_application.user
    end

    def schedule
      case npq_application.npq_course.identifier
      when *NPQCourse::LEADERSHIP_IDENTIFIER
        Finance::Schedule::NPQLeadership.default
      when *NPQCourse::SPECIALIST_IDENTIFIER
        Finance::Schedule::NPQSpecialist.default
      when "npq-additional-support-offer"
        # TODO: Figure out what ASO schedules look like
        Finance::Schedule::NPQSpecialist.default
      else
        raise ArgumentError "Invalid course identifier"
      end
    end

    def npq_course
      npq_application.npq_course
    end
  end
end
