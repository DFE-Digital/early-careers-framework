# frozen_string_literal: true

module Participants
  module ProfileAttributes
    extend ActiveSupport::Concern
    include ActiveModel::Validations

    included do
      attr_accessor :course_identifier, :participant_id, :cpd_lead_provider
      validates :course_identifier, presence: { message: I18n.t(:missing_course_identifier) }
      validates :participant_id, presence: { message: I18n.t(:invalid_participant) }
      validates :participant_id, format: /\A[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\Z/, allow_blank: true
      validates :cpd_lead_provider, presence: { message: I18n.t(:missing_lead_provider) }
      validate :valid_course_for_participant
      validate :existing_profile
    end

    def valid_courses
      self.class.valid_courses
    end

    def valid_course_for_participant
      return if errors.any?

      errors.add(:course_identifier, I18n.t(:invalid_identifier)) unless valid_courses.include?(course_identifier)
    end

    def user
      @user ||= User.find_by(id: participant_id)
    end

    def existing_profile
      return if errors.any?

      errors.add(:participant_id, I18n.t(:invalid_participant)) if user_profile.blank?
    end
  end
end
