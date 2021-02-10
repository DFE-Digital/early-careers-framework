class Registrations::QuestionOneController < ApplicationController
  def show
    @school = School.new
    @options = [
      OpenStruct.new(id: 1, name: "Yes"),
      OpenStruct.new(id: 2, name: "I don't know yet")
    ]
  end
end
