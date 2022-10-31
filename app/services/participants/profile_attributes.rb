# frozen_string_literal: true

module Participants
  module ProfileAttributes
    extend ActiveSupport::Concern
    include ActiveModel::Validations

    included do
      attr_accessor :course_identifier, :participant_id, :cpd_lead_provider

      validates :course_identifier, course: true, presence: { message: I18n.t(:missing_course_identifier) }
      validates :participant_id, presence: { message: I18n.t(:missing_participant_id) }
      validates :cpd_lead_provider, presence: { message: I18n.t(:missing_cpd_lead_provider) }
      validates :participant_id, format: /\A[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\Z/, allow_blank: true
      validate :course_valid_for_participant
      validate :participant_has_user_profile
    end

    def course_valid_for_participant
      return if errors.any?

      errors.add(:course_identifier, I18n.t(:invalid_identifier)) unless valid_courses.include?(course_identifier)
    end

    def participant_has_user_profile
      return if errors.any?

      errors.add(:participant_id, I18n.t(:invalid_participant)) if user_profile.blank?
    end

    def participant_identity
      @participant_identity ||= ParticipantIdentity.find_by(external_identifier: participant_id)
    end

  private

    def user
      @user ||= participant_identity&.user
    end

    def valid_courses
      self.class.valid_courses
    end
  end
end
