# frozen_string_literal: true

module Finance
  class ParticipantsController < BaseController
    before_action :find_user_by_id_or_external_id

    def index
      if params[:query]
        if @user
          redirect_to finance_participant_path(@user)
        else
          flash.now[:alert] = "No user found"
        end
      end
    end

    def show; end

  private

    def find_user_by_id_or_external_id
      query = params[:query] || params[:id]
      @user = Identity.find_user_by(id: query) || NPQApplication.find_by(id: query)&.user
    end
  end
end
