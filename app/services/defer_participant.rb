# frozen_string_literal: true

require "factories/course_identifier"

class WithdrawParticipant
  attr_accessor :params

  class << self
    def call(params)
      new(params).call
    end
  end

  def call
    recorder = "::Participants::Defer::#{::Factories::CourseIdentifier.call(course_identifier)}".constantize
    recorder.call(params: params)
  end

private

  def initialize(params)
    @params = params
  end

  def course_identifier
    params[:course_identifier]
  end
end
