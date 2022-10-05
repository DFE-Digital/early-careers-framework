# frozen_string_literal: true

module AppropriateBodies
  class ParticipantsController < BaseController
    def index
      appropriate_body
    end

  private

    def appropriate_body
      @appropriate_body ||= current_user.appropriate_bodies.find(params[:appropriate_body_id])
    end
  end
end
