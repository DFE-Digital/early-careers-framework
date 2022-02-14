# frozen_string_literal: true

class ChallengePartnershipsController < ApplicationController
  include Pundit
  include Multistep::Controller
  form ChallengePartnershipForm, as: :challenge_partnership_form

  before_action :check_partnership

  setup_form do |form|
    form.partnership = partnership
  end

  abandon_journey_path { root_path }

  def link_expired; end
  def already_challenged; end
  def already_started; end

private

  def check_partnership
    redirect_to action: :already_challenged and return if partnership.challenged?
    redirect_to action: :link_expired and return unless partnership.in_challenge_window?

    participants = ParticipantProfile::ECF.where(school_cohort: SchoolCohort.where(school: partnership.school, cohort: partnership.cohort))
    declarations_present = ParticipantDeclaration.not_voided.where(participant_profile: participants).exists?

    redirect_to action: :already_started and return if declarations_present
  end

  def partnership
    return @partnership if defined?(@partnership)
    return @partnership = form.partnership unless action_name == 'start'

    @partnership = if params[:token].present?
                     notification_email = PartnershipNotificationEmail.find_by!(token: params[:token])
                     notification_email.partnership
                   elsif params[:partnership].present?
                     authorize Partnership.find(params[:partnership]), :update?
                   else
                     raise ActionController::RoutingError, I18n.t(:not_found)
                   end
  end
end
