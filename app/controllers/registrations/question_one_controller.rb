# frozen_string_literal: true

class Registrations::QuestionOneController < ApplicationController
  def show
    @options = [
      OpenStruct.new(id: 1, name: "Yes"),
      OpenStruct.new(id: 2, name: "I don't know yet"),
    ]
  end

  def create
    if params[:answer] == "1"
      redirect_to :registrations_question_two
    else
      redirect_to :registrations_no_participants
    end
  end
end
