# frozen_string_literal: true

require "factories/course_identifier"
require "factories/event"

class RecordParticipantDeclaration
  attr_accessor :params

  class << self
    def call(params)
      new(params).call
    end
  end

  def call
    recorder = "::RecordDeclarations::#{::Factories::Event.call(event)}::#{::Factories::CourseIdentifier.call(course_identifier)}".constantize
    recorder.call(params)
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
