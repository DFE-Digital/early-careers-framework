# frozen_string_literal: true

class RecordParticipantDeclaration
  attr_accessor :params

  class << self
    def call(params)
      new(params).call
    end
  end

  def call
    RecordDeclarations::RecorderFactory.call(course).call(params)
  rescue NameError
    raise ActionController::ParameterMissing, I18n.t(:invalid_course)
  end

private

  def initialize(params)
    @params = params
    @params[:user_id] = params[:participant_id]
  end

  def course
    params[:course_identifier]
  end
end
