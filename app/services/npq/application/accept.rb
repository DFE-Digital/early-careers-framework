# frozen_string_literal: true

module NPQ
  module Application
    class Accept
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :npq_application
      attribute :schedule_identifier
      attribute :funded_place

      validates :npq_application, presence: { message: I18n.t("npq_application.missing_npq_application") }
      validate :not_already_accepted
      validate :cannot_change_from_rejected
      validate :other_accepted_applications_with_same_course?
      validate :validate_permitted_schedule_for_course
      validate :eligible_for_funded_place
      validate :validate_funded_place

      def call
        return self unless valid?

        ApplicationRecord.transaction do
          teacher_profile.update!(trn: npq_application.teacher_reference_number) if npq_application.teacher_reference_number_verified?
          create_participant_profile!
          npq_application.update!(lead_provider_approval_status: "accepted")
          other_applications_in_same_cohort.update(lead_provider_approval_status: "rejected") # rubocop:disable Rails/SaveBang
          deduplicate_by_trn!
          set_funded_place_on_npq_application
        end

        npq_application
      end

    private

      def not_already_accepted
        return if npq_application.blank?

        errors.add(:npq_application, I18n.t("npq_application.has_already_been_accepted")) if npq_application.accepted?
      end

      def cannot_change_from_rejected
        return if npq_application.blank?

        errors.add(:npq_application, I18n.t("npq_application.cannot_change_from_rejected")) if npq_application.rejected?
      end

      def cohort
        npq_application.cohort
      end

      def other_accepted_applications_with_same_course?
        errors.add(:npq_application, I18n.t("npq_application.has_another_accepted_application")) if other_accepted_applications_with_same_course.present?
      end

      def other_accepted_applications_with_same_course
        return if npq_application.blank?

        @other_accepted_applications_with_same_course ||= NPQApplication
                                                            .joins(:participant_identity)
                                                            .where(lead_provider_approval_status: "accepted", npq_course: npq_course.rebranded_alternative_courses, participant_identity: { user: [user, same_trn_user] })
                                                            .where.not(id: npq_application.id)
      end

      def other_applications_in_same_cohort
        @other_applications_in_same_cohort ||= NPQApplication
          .joins(:participant_identity)
          .where(cohort:, npq_course:, participant_identity: { user_id: user.id })
          .where.not(id: npq_application.id)
      end

      def alias_search_query
        Finance::Schedule::NPQ
          .where.not(identifier_alias: nil)
          .where(identifier_alias: schedule_identifier, cohort:)
      end

      def new_schedule
        Finance::Schedule::NPQ
          .where(schedule_identifier:, cohort:)
          .or(alias_search_query)
          .first
      end

      def schedule
        @schedule ||= schedule_identifier.present? ? new_schedule : fallback_schedule
      end

      def fallback_schedule
        NPQCourse.schedule_for(npq_course: npq_application.npq_course, cohort:)
      end

      def create_participant_profile!
        ParticipantProfile::NPQ.create!(
          id: npq_application.id,
          schedule:,
          npq_course: npq_application.npq_course,
          teacher_profile:,
          school_urn: npq_application.school_urn,
          school_ukprn: npq_application.school_ukprn,
          participant_identity: npq_application.participant_identity,
        ).tap do |pp|
          ParticipantProfileState.find_or_create_by(participant_profile: pp)
        end
      end

      def participant_profile
        @participant_profile ||= ParticipantProfile.find(npq_application.id)
      end

      def trn
        @trn ||= npq_application.teacher_reference_number_verified? ? npq_application.teacher_reference_number : teacher_profile&.trn
      end

      def teacher_profile
        @teacher_profile ||= user.teacher_profile || user.build_teacher_profile
      end

      def user
        @user ||= npq_application.participant_identity.user
      end

      def same_trn_user
        return if trn.blank?

        @same_trn_user ||= TeacherProfile
                           .oldest_first
                           .where(trn:)
                           .where.not(id: teacher_profile.id)
                           .first
                           &.user
      end

      def npq_course
        npq_application.npq_course
      end

      def deduplicate_by_trn!
        NPQ::DedupeParticipant.new(npq_application:, trn: teacher_profile.trn).call
      end

      def validate_permitted_schedule_for_course
        return if errors.any?
        return if schedule_identifier.blank?

        unless schedule && schedule.class::PERMITTED_COURSE_IDENTIFIERS.include?(npq_application.npq_course.identifier)
          errors.add(:schedule_identifier, I18n.t(:schedule_invalid_for_course))
        end
      end

      def set_funded_place_on_npq_application
        return unless FeatureFlag.active?("npq_capping")
        return unless npq_contract.funding_cap.to_i.positive?

        npq_application.update!(funded_place:)
      end

      def eligible_for_funded_place
        return unless FeatureFlag.active?("npq_capping")
        return if errors.any?
        return unless npq_contract.funding_cap.to_i.positive?

        if funded_place && !npq_application.eligible_for_funding
          errors.add(:npq_application, I18n.t("npq_application.not_eligible_for_funded_place"))
        end
      end

      def validate_funded_place
        return unless FeatureFlag.active?("npq_capping")
        return if errors.any?
        return unless npq_contract.funding_cap.to_i.positive?

        if funded_place.nil?
          errors.add(:npq_application, I18n.t("npq_application.funded_place_required"))
        end
      end

      def npq_contract
        @npq_contract ||=
          NPQContract.where(
            cohort_id: cohort.id,
            npq_lead_provider_id: npq_application.npq_lead_provider_id,
            course_identifier: npq_application.npq_course.identifier,
            version: statement.contract_version,
          ).first
      end

      def statement
        npq_application.npq_lead_provider.next_output_fee_statement(cohort)
      end
    end
  end
end
