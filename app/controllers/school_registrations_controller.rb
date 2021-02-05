# frozen_string_literal: true

class SchoolsController < ApplicationController

  def academic_year
    options = [
      OpenStruct.new(id: 1, name: "Yes"),
      OpenStruct.new(id: 2, name: "No"),
      OpenStruct.new(id: 3, name: "I don't know yet")
    ]
  end
end
