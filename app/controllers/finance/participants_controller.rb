# frozen_string_literal: true

module Finance
  class ParticipantsController < BaseController
    def index
      if params[:query]
        @user = User.find_by(id: params[:query].strip)

        if @user
          redirect_to finance_participant_path(@user)
        else
          flash.now[:alert] = "No user found"
        end
      end
    end

    def show
      @user = User.includes(:participant_profiles).find(params[:id])
    end
  end
end
