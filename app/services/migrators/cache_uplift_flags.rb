# frozen_string_literal: true

module Migrators
  class CacheUpliftFlags
    def call
      declarations.find_each do |declaration|
        profile = declaration.participant_profile

        declaration.update!(
          pupil_premium_uplift: profile.pupil_premium_uplift,
          sparsity_uplift: profile.sparsity_uplift,
        )
      end
    end

  private

    def declarations
      @declarations ||= ParticipantDeclaration.includes(:participant_profile)
    end
  end
end
