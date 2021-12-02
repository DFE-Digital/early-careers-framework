# frozen_string_literal: true

class TransferUserIdentity < BaseService
  def call
    from_user.participant_identities.each do |identity|
      identity.update!(user: to_user)
      identity.participant_profiles.each do |profile|
        # NOTE: this might currently make the profile disappear from the ecf participants api endpoint
        # because it limits one entry per teacher_profile
        profile.update!(teacher_profile: to_user.teacher_profile)
      end
    end
  end

private

  attr_accessor :from_user, :to_user

  def initialize(from_user:, to_user:)
    @from_user = from_user
    @to_user = to_user
  end
end
