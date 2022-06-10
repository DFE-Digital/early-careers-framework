# frozen_string_literal: true

module NPQ
  class Accept
    class << self
      def call(npq_application:)
        new(npq_application:).call
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

      if npq_application.rejected?
        npq_application.errors.add(:lead_provider_approval_status, :cannot_change_from_rejected)
        return false
      end

      ApplicationRecord.transaction do
        teacher_profile.update!(trn: npq_application.teacher_reference_number) if npq_application.teacher_reference_number_verified?
        participant_profile
        result = npq_application.update(lead_provider_approval_status: "accepted") && other_applications_in_same_cohort.update(lead_provider_approval_status: "rejected")
        deduplicate_by_trn!
        result
      end
    end

  private

    def cohort
      npq_application.cohort
    end

    def has_other_accepted_applications_with_same_course?
      NPQApplication.joins(:participant_identity)
        .where(participant_identity: { user_id: user.id })
        .where(npq_course: npq_course.rebranded_alternative_courses)
        .where(lead_provider_approval_status: "accepted")
        .where.not(id: npq_application.id)
        .exists?
    end

    def other_applications_in_same_cohort
      @other_applications_in_same_cohort ||= NPQApplication
        .joins(:participant_identity)
        .where(participant_identity: { user_id: user.id })
        .where(npq_course:)
        .where(cohort:)
        .where.not(id: npq_application.id)
    end

    def participant_profile
      @participant_profile ||= ParticipantProfile::NPQ.create!(
        id: npq_application.id,
        schedule: NPQCourse.schedule_for(npq_course: npq_application.npq_course, cohort:),
        npq_course: npq_application.npq_course,
        teacher_profile:,
        school_urn: npq_application.school_urn,
        school_ukprn: npq_application.school_ukprn,
        participant_identity: npq_application.participant_identity,
      ).tap do |pp|
        pp.participant_profile_states.create!
      end
    end

    def teacher_profile
      @teacher_profile ||= user.teacher_profile || user.build_teacher_profile
    end

    def user
      @user ||= npq_application.participant_identity.user
    end

    def npq_course
      npq_application.npq_course
    end

    def deduplicate_by_trn!
      return if participant_profile.teacher_profile.trn.blank?

      same_trn_user = TeacherProfile
        .where(trn: participant_profile.teacher_profile.trn)
        .where.not(id: participant_profile.teacher_profile.id)
        .first
        &.user

      Identity::Transfer.call(from_user: participant_profile.user, to_user: same_trn_user) if same_trn_user
    end
  end
end
