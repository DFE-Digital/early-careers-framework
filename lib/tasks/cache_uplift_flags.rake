# frozen_string_literal: true

namespace :cache_uplift_flags do
  desc "backfills pupil_premium_uplift and sparsity_uplift on declarations"
  task update_declarations: :environment do

    ParticipantDeclaration.includes(:participant_profile).find_each do |declaration|
      profile = declaration.participant_profile

      declaration.update_columns(
        pupil_premium_uplift: profile.pupil_premium_uplift,
        sparsity_uplift: profile.sparsity_uplift,
        )
    end
  end
end
