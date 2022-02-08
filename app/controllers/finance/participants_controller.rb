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
      @user = Identity.find_user_by(id: params[:query] || params[:id])
    end
  end
end
