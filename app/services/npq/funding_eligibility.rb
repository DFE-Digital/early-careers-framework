# frozen_string_literal: true

module NPQ
  class FundingEligibility
    attr_reader :trn, :npq_course_identifier

    def initialize(trn:, npq_course_identifier:)
      @trn = trn
      @npq_course_identifier = npq_course_identifier
    end

    def call
      {
        previously_funded: previously_funded?,
        previously_received_targeted_funding_support: previously_received_targeted_funding_support?,
      }
    end

  private

    def npq_course
      @npq_course ||= NPQCourse.find_by!(identifier: npq_course_identifier)
    end

    def npq_course_and_rebranded_alternatives
      npq_course.rebranded_alternative_courses
    end

    def users
      User.where(teacher_profile: teacher_profiles)
    end

    def teacher_profiles
      @teacher_profiles ||= TeacherProfile.where(trn:)
    end

    def accepted_applications
      @accepted_applications ||= begin
        application_ids = users.flat_map do |user|
          user.npq_applications
              .where(npq_course: npq_course_and_rebranded_alternatives)
              .where(eligible_for_funding: true)
              .accepted
              .pluck(:id)
        end

        NPQApplication.where(id: application_ids)
      end
    end

    def previously_funded?
      accepted_applications.any?
    end

    def previously_received_targeted_funding_support?
      accepted_applications.with_targeted_delivery_funding_eligibility.any?
    end
  end
end
