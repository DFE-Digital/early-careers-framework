# frozen_string_literal: true

require "identity/create"

module Identity
  def self.find_user_by(params = {})
    if params.key?(:id)
      id = params[:id]
      User.find_by(id:) || ParticipantIdentity.find_by(external_identifier: id)&.user
    elsif params.key?(:email)
      email = params[:email]
      ParticipantIdentity.find_by(email:)&.user || User.find_by(email:)
    else
      User.find_by(params)
    end
  end
end
