# frozen_string_literal: true

class SchoolRegistrationsController < ApplicationController

  def academic_year
    @school = School.new
    @options = [
      OpenStruct.new(id: 1, name: "Yes"),
      OpenStruct.new(id: 2, name: "I don't know yet")
    ]
  end
end
