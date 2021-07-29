# frozen_string_literal: true

require "record_declarations/recorder_factory"
require "record_declarations/event_factory"

class RecordParticipantDeclaration
  attr_accessor :params

  class << self
    def call(params)
      new(params).call
    end
  end

  def call
    recorder = "::RecordDeclarations::#{::RecordDeclarations::EventFactory.call(event)}::#{::RecordDeclarations::RecorderFactory.call(course_identifier)}".constantize
    recorder.call(params)
  rescue NameError
    raise ActionController::ParameterMissing, I18n.t(:invalid_course)
  end

private

  def initialize(params)
    @params = params
  end

  def course_identifier
    params[:course_identifier]
  end

  def event
    params[:declaration_type]
  end
end
