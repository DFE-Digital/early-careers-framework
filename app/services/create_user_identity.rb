# frozen_string_literal: true

class CreateUserIdentity < BaseService
  def call
    ParticipantIdentity.find_or_create_by!(email: user.email) do |identity|
      identity.user = user
      identity.external_identifier = user.id
      identity.email = user.email
      identity.origin = origin
    end
  end

private

  attr_accessor :user, :origin

  def initialize(user:, origin: :ecf)
    @user = user
    @origin = origin
  end
end
