# frozen_string_literal: true

module Finance
  class ParticipantsController < BaseController
    before_action :find_user_by_query

    def index
      if params[:query]
        if @user
          redirect_to finance_participant_path(@user)
        else
          flash.now[:alert] = "No records found"
        end
      end
    end

    def show; end

  private

    def find_user_by_query
      query = params[:query] || params[:id]
      @user = Identity.find_user_by(id: query) ||
        NPQApplication.find_by(id: query)&.user ||
        ParticipantDeclaration.find_by(id: query)&.user
    end
  end
end
