# frozen_string_literal: true

module NominationEmailTokenConsumer
  extend ActiveSupport::Concern

private

  def check_token_status
    if nomination_email.nil?
      redirect_to link_invalid_nominate_induction_coordinator_path
    elsif nomination_email.expired?
      redirect_to link_expired_nominate_induction_coordinator_path(school_id: nomination_email.school_id)
    end
  end

  def token
    @token ||= (params[:token] || @nominate_induction_tutor_form&.token)
  end

  def nomination_email
    @nomination_email ||= NominationEmail.find_by(token:)
  end

  def school
    nomination_email&.school
  end

  def record_nomination_email_opened
    NominationEmail
      .where(token: nomination_email.token, opened_at: nil)
      .update_all(opened_at: Time.zone.now)
  end
end
