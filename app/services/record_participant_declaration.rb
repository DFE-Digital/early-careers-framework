# frozen_string_literal: true

class RecordParticipantDeclaration
  attr_accessor :params

  class << self
    def call(params)
      new(params).call
    end
  end

  def call
    RecordDeclarations::RecorderFactory.call(course_identifier).call(params)
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
end
