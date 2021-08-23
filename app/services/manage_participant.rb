# frozen_string_literal: true

require "factories/course_identifier"

class ManageParticipant
  attr_accessor :params

  class << self
    def call(params)
      new(params).call
    end

    def valid_actions
      HashWithIndifferentAccess.new(
        withdraw: "Withdraw",
      ).freeze
    end
  end

  def call
    raise ActionController::ParameterMissing, I18n.t(:invalid_action) unless valid_actions[action]

    recorder = "::Participants::#{valid_actions[action]}::#{::Factories::CourseIdentifier.call(course_identifier)}".constantize
    recorder.call(params: params.except(:action))
  end

private

  def initialize(params)
    @params = params
  end

  def course_identifier
    params[:course_identifier]
  end

  def action
    params[:action]
  end

  def valid_actions
    self.class.valid_actions
  end
end
