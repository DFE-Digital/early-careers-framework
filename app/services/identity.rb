# frozen_string_literal: true

module Identity
  def self.find_user_by(params = {})
    if params.key?(:id)
      id = params[:id]
      ParticipantIdentity.find_by(external_identifier: id)&.user || User.find_by(id: id)
    elsif params.key?(:email)
      email = params[:email]
      ParticipantIdentity.find_by(email: email)&.user || User.find_by(email: email)
    else
      User.find_by(params)
    end
  end
end
