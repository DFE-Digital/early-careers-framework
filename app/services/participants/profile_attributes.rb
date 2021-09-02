# frozen_string_literal: true

module Participants
  module ProfileAttributes
    extend ActiveSupport::Concern
    include ActiveModel::Validations

    included do
      attr_accessor :course_identifier, :participant_id, :cpd_lead_provider
      validates :participant_id, :course_identifier, :cpd_lead_provider, presence: true
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

  private

    def user
      @user ||= User.find_by(id: participant_id)
    end

    def valid_courses
      self.class.valid_courses
    end
  end
end
