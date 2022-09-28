# frozen_string_literal: true

module Admin::Participants::NPQ
  class ChangeEmailController < Admin::BaseController
    def edit
      @participant_profile = retrieve_participant_profile
      @email_form = build_email_form(@participant_profile, email: @participant_profile.user.email)
    end

    def update
      @participant_profile = retrieve_participant_profile
      @email_form = build_email_form(@participant_profile, **change_email_params_hash)

      old_email = @participant_profile.user.email
      new_email = @email_form.email

      if old_email == new_email
        redirect_to(admin_participant_path(@participant_profile))
      elsif @email_form.save
        flash[:success] = { title: "Email address changed", content: "#{old_email} changed to #{new_email}" }

        redirect_to(admin_participant_path(@participant_profile))
      else
        render :edit
      end
    end

  private

    def change_email_params_hash
      change_email_params.to_h.symbolize_keys
    end

    def change_email_params
      params.require(:admin_participants_npq_change_email_form).permit(:email)
    end

    def build_email_form(participant_profile, email:)
      Admin::Participants::NPQ::ChangeEmailForm.new(participant_profile.user, email:)
    end

    def retrieve_participant_profile
      policy_scope(ParticipantProfile::NPQ).eager_load(:user).find(params[:participant_id]).tap do |participant_profile|
        authorize participant_profile, policy_class: participant_profile.policy_class
      end
    end
  end
end
