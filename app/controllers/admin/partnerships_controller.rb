# frozen_string_literal: true

module Admin
  class PartnershipsController < Admin::BaseController
    skip_after_action :verify_policy_scoped
    before_action :load_partnership, only: %i[show reject]

    def show
      authorize @partnership
      @reasons_for_rejection = [
        OpenStruct.new(id: :partnered_with_another_provider, name: "I have already partnered with a different training provider"),
        OpenStruct.new(id: :provider_not_known, name: "I don't recognise this training provider"),
        OpenStruct.new(id: :change_of_mind, name: "I have changed my mind"),
        OpenStruct.new(id: :no_induction, name: "I'm not doing any inductions this year"),
        OpenStruct.new(id: :mistake, name: "This looks like a mistake"),
        OpenStruct.new(id: :other, name: "Other"),
      ]
    end

    def reject
      authorize @partnership, :update?
      if @partnership.update(reject_params)
        redirect_to admin_partnership_path(@partnership), notice: "Partnership successfully rejected"
      else
        render :show
      end
    end

  private

    def load_partnership
      @partnership = Partnership.find(params[:id])
    end

    def reject_params
      params
      .require(:partnership)
      .permit(:reason_for_rejection)
      .merge(status: "rejected", rejected_at: Time.zone.now)
    end
  end
end
