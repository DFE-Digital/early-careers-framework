# frozen_string_literal: true

require "rake"

namespace :one_off do
  desc "Transition submitted npq declarations to eligible if they are eligible for funding"
  task transition_eligible_npq_declarations: :environment do
    PaperTrail.request.controller_info = {
      reason: "Backfilling updates to npq participant declarations from submitted to eligible",
    }

    declarations_to_transition = ParticipantDeclaration::NPQ.joins(:npq_application).where(
      state: "submitted",
      declaration_type: "started",
      npq_applications: { eligible_for_funding: true },
    )

    count = declarations_to_transition.count
    puts "#{count} declarations to transition"

    declarations_to_transition.each(&:make_eligible!)

    puts "#{count} declarations transitioned from submitted to eligible"
  end
end
