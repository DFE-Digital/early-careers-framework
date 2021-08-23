# frozen_string_literal: true

module Participants
  module ProfileAttributes
    extend ActiveSupport::Concern
    include ActiveModel::Validations

    included do
      attr_accessor :course_identifier, :participant_id, :cpd_lead_provider
      validates :course_identifier, :participant_id, :cpd_lead_provider, presence: true
      validates :course_identifier, inclusion: { in: :valid_courses_for_user, message: I18n.t(:invalid_identifier) }, allow_blank: true
      validates :participant_id, format: /\A[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\Z/
      validate :existing_profile
    end

    def valid_courses_for_user
      self.class.valid_courses_for_user
    end

    def user
      @user ||= User.find_by(id: participant_id)
    end

    def existing_profile
      errors.add(:participant_id, I18n.t(:invalid_participant)) if user_profile.blank?
    end
  end
end
