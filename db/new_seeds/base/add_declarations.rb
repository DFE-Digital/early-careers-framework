# frozen_string_literal: true

require "active_support/testing/time_helpers"

ActiveRecord::Base.transaction do
  include ActiveSupport::Testing::TimeHelpers

  CpdLeadProvider.joins(:lead_provider).find_each do |cpd_lead_provider|
    lead_provider = cpd_lead_provider.lead_provider

    # Ensure there are some participants for
    # the lead provider in all cohorts.
    Cohort.find_each do |cohort|
      Faker::Number.between(from: 1, to: 20).times do
        # Ensure there is a default and extended finance schedules for the cohort.
        FactoryBot.create(:ecf_schedule, cohort:) unless Finance::Schedule::ECF.exists?(cohort:, schedule_identifier: "ecf-standard-september")
        FactoryBot.create(:ecf_extended_schedule, cohort:) unless Finance::Schedule::ECF.exists?(cohort:, schedule_identifier: "ecf-extended-september")

        FactoryBot.create(:ect, :eligible_for_funding, cohort:, lead_provider:)
        FactoryBot.create(:mentor, :eligible_for_funding, cohort:, lead_provider:)
        FactoryBot.create(:ect, :eligible_for_funding, :with_extended_schedule, cohort:, lead_provider:)
        FactoryBot.create(:mentor, :eligible_for_funding, :with_extended_schedule, cohort:, lead_provider:)
      end
    end

    lead_provider.active_ecf_participant_profiles.each do |participant_profile|
      # ~5% of participants will not have a declaration.
      next if Faker::Boolean.boolean(true_ratio: 0.05)

      # Ignore participants without induction records for the lead provider.
      induction_record = participant_profile.current_induction_record
      schedule = induction_record.schedule
      next if Induction::FindBy.call(participant_profile:, lead_provider:, schedule:).blank?

      # Possible declaration states.
      states = ParticipantDeclaration.states.keys
      fundable_states = %w[payable paid awaiting_clawback clawed_back]
      states.reject! { |state| state.in?(fundable_states) } unless participant_profile.fundable?
      state = states.sample

      # Possible declaration types.
      declaration_types = %w[started retained-1 retained-2 retained-3 retained-4 extended-1 extended-2 extended-3 completed]
      existing_declaration_types = participant_profile.participant_declarations.pluck(:declaration_type)
      declaration_types.reject! { |type| type.in?(existing_declaration_types) }
      declaration_types.reject! { |type| type.match?(/retained|extended/) } if participant_profile.mentor? && schedule.cohort.mentor_funding?
      declaration_types.reject! { |type| type.match?(/extended/) } unless schedule.schedule_identifier.match?(/extended/)

      declaration_types.each do |declaration_type|
        # Keep creating declarations with a 50% chance.
        break unless Faker::Boolean.boolean(true_ratio: 0.5)

        # Ensure there is a milestone for the declaration type.
        FactoryBot.create(:milestone, schedule:, declaration_type:, start_date: 1.day.ago) unless schedule.milestones.exists?(declaration_type:)

        # We can't create a declaration if the schedule milestone is in the future,
        # so we travel to the milestone start_date first.
        milestone_start_date = schedule.milestones.find_by(declaration_type:).start_date

        travel_to milestone_start_date do
          # Create declaration of correct type.
          type = participant_profile.ect? ? :ect : :mentor
          FactoryBot.create(
            "#{type}_participant_declaration",
            state,
            declaration_type:,
            participant_profile:,
            cpd_lead_provider:,
            cohort: schedule.cohort,
          )
        end
      end
    end
  end
end
