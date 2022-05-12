# frozen_string_literal: true

require "rake"

namespace :update_participant_profile_states do
  desc "Back filling cpd_lead_providers on participant_profile_states"
  task populate_cpd_lead_provider: :environment do
    PaperTrail.request.controller_info = {
      reason: "Back filling cpd_lead_providers on participant_profile_states",
    }

    participant_profiles_with_a_single_induction_record = ParticipantProfile.joins(:induction_records).group(:id).having("count(*) < 2")

    participant_profiles_with_a_single_induction_record.each do |pp|
      pp.participant_profile_states.each do |ps|
        ps.update_column(:cpd_lead_provider_id, pp.school&.partnerships&.first&.lead_provider&.cpd_lead_provider&.id)
      end
    end
  end
end
