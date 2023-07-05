# frozen_string_literal: true

module Api::V3::Concerns::FilterTrainingStatus
  extend ActiveSupport::Concern

protected

  def filter
    params[:filter] ||= {}
  end

  def training_status_filter
    filter[:training_status].to_s
  end

  def training_status
    return if training_status_filter.blank?

    unless training_status_filter.in?(valid_training_status)
      raise Api::Errors::InvalidTrainingStatusError, I18n.t(:invalid_training_status, valid_training_status:)
    end

    training_status_filter
  end

  def valid_training_status
    ParticipantProfile.training_statuses.keys
  end
end
