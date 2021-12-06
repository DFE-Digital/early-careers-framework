# frozen_string_literal: true

module Identity
  class Transfer < BaseService
    def call
      ActiveRecord::Base.transaction do
        teacher_profile = TeacherProfile.find_or_create_by!(user: to_user)

        from_user.participant_identities.each do |identity|
          identity.update!(user: to_user)
          identity.participant_profiles.each do |profile|
            profile.update!(teacher_profile: teacher_profile)
          end
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
end
