# frozen_string_literal: true

module NPQ
  class FundingEligibility
    attr_reader :npq_course_identifier,
                :trn,
                :get_an_identity_id

    def initialize(npq_course_identifier:, trn: nil, get_an_identity_id: nil)
      @trn = trn
      @get_an_identity_id = get_an_identity_id
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
      get_an_identity_id_users.or(trn_users).distinct
    end

    def get_an_identity_id_users
      return User.none if get_an_identity_id.blank?

      User.where(get_an_identity_id:)
    end

    def trn_users
      return User.none if trn.blank?

      User.where(teacher_profile: teacher_profiles_with_trn)
    end

    def teacher_profiles_with_trn
      @teacher_profiles_with_trn ||= TeacherProfile.where(trn:)
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
