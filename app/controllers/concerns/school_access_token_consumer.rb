# frozen_string_literal: true

module SchoolAccessTokenConsumer
  extend ActiveSupport::Concern

  included do
    before_action :store_token
  end

private

  LEGACY_EMAILS_PERMISSIONS = {
    NominationEmail => [:nominate_tutor],
    PartnershipNotificationEmail => [:challenge_partnership],
  }.freeze

  def store_token
    handle_legacy_email_records
    session[:access_token] = params[:token] if params[:token]
  end

  def access_token
    @access_token ||= SchoolAccessToken.find_by(token: session[:access_token])
  end

  def require_access_token!(action)
    return if access_token.permits?(action)

    raise Pundit::NotAuthorizedError, "Access token does not permit #{action}"
  end

  # TODO: Delete this when all the NominationEmail and PartnershipNotificationEmail tokens expires
  def handle_legacy_email_records
    return if legacy_record.blank?

    # We're handling an email that was sent before SchoolAccessToken deployment.
    access_token = SchoolAccessToken.find_or_create_by!(token: "legacy-#{legacy_record.token}") do |sat|
      sat.permitted_actions = LEGACY_EMAILS_PERMISSIONS[legacy_record.class]
      sat.school = legacy_record.school
    end
    params[:token] = access_token.token
  end

  def associated_email_records
    [
      Email.associated_with(access_token).first,
      legacy_record,
    ].compact
  end

  def legacy_record
    return @legacy_record if defined?(@legacy_record)

    @legacy_record = [NominationEmail, PartnershipNotificationEmail].find do |email_class|
      record = email_class.find_by(token: params[:token])
      break record if record
    end
  end
end
