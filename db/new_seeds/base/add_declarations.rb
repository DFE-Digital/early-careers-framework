# frozen_string_literal: true

require "active_support/testing/time_helpers"
include ActiveSupport::Testing::TimeHelpers

# Configuration - adjust batch sizes based on your system capabilities
LEAD_PROVIDER_BATCH_SIZE = 5
PARTICIPANT_BATCH_SIZE = 100
COHORT_BATCH_SIZE = 10

# Pre-load all cohorts to avoid repeated queries
cohorts = Cohort.all.to_a

# Pre-create schedules for all cohorts in bulk
cohort_ids_without_standard_schedule = cohorts.reject { |c| Finance::Schedule::ECF.exists?(cohort: c, schedule_identifier: "ecf-standard-september") }.map(&:id)
cohort_ids_without_extended_schedule = cohorts.reject { |c| Finance::Schedule::ECF.exists?(cohort: c, schedule_identifier: "ecf-extended-september") }.map(&:id)

if cohort_ids_without_standard_schedule.any?
  cohort_ids_without_standard_schedule.each_slice(COHORT_BATCH_SIZE) do |cohort_ids_batch|
    ActiveRecord::Base.transaction do
      cohort_ids_batch.each do |cohort_id|
        cohort = cohorts.find { |c| c.id == cohort_id }
        FactoryBot.create(:ecf_schedule, cohort:)
      end
    end
  end
end

if cohort_ids_without_extended_schedule.any?
  cohort_ids_without_extended_schedule.each_slice(COHORT_BATCH_SIZE) do |cohort_ids_batch|
    ActiveRecord::Base.transaction do
      cohort_ids_batch.each do |cohort_id|
        cohort = cohorts.find { |c| c.id == cohort_id }
        FactoryBot.create(:ecf_extended_schedule, cohort:)
      end
    end
  end
end

# Process lead providers in batches
cpd_lead_providers = CpdLeadProvider.joins(:lead_provider).to_a

cpd_lead_providers.each_slice(LEAD_PROVIDER_BATCH_SIZE) do |cpd_lead_provider_batch|
  cpd_lead_provider_batch.each do |cpd_lead_provider|
    lead_provider = cpd_lead_provider.lead_provider

    # Create participants for each cohort in batches
    cohorts.each do |cohort|
      participant_count = Faker::Number.between(from: 1, to: 20)

      # Create participants in a single transaction per cohort
      ActiveRecord::Base.transaction do
        participant_count.times do
          FactoryBot.create(:ect, :eligible_for_funding, cohort:, lead_provider:, user: FactoryBot.create(:user, full_name: Faker::Name.name))
          FactoryBot.create(:mentor, :eligible_for_funding, cohort:, lead_provider:, user: FactoryBot.create(:user, full_name: Faker::Name.name))
          FactoryBot.create(:ect, :eligible_for_funding, :with_extended_schedule, cohort:, lead_provider:, user: FactoryBot.create(:user, full_name: Faker::Name.name))
          FactoryBot.create(:mentor, :eligible_for_funding, :with_extended_schedule, cohort:, lead_provider:, user: FactoryBot.create(:user, full_name: Faker::Name.name))
        end
      end
    end

    # Process participant profiles in batches
    active_profiles = lead_provider.active_ecf_participant_profiles.to_a

    # Pre-calculate possible states and declaration types to avoid repeated calculations
    states = ParticipantDeclaration.states.keys
    declaration_types = %w[started retained-1 retained-2 retained-3 retained-4 extended-1 extended-2 extended-3 completed]

    active_profiles.each_slice(PARTICIPANT_BATCH_SIZE) do |profile_batch|
      # Group profiles by schedule to reduce database lookups
      profiles_by_schedule = {}

      profile_batch.each do |participant_profile|
        # Skip ~5% of participants (no declaration)
        next if Faker::Boolean.boolean(true_ratio: 0.05)

        induction_record = participant_profile.current_induction_record
        next unless induction_record # Skip if no induction record

        schedule = induction_record.schedule
        next unless schedule # Skip if no schedule

        # Check if participant has an induction for this lead provider and schedule
        next if Induction::FindBy.call(
          participant_profile:,
          lead_provider:,
          schedule:,
        ).blank?

        # Group by schedule to create milestones efficiently
        profiles_by_schedule[schedule] ||= []
        profiles_by_schedule[schedule] << participant_profile
      end

      # Process each schedule group
      profiles_by_schedule.each do |schedule, profiles|
        # Pre-create all needed milestones for this schedule in one batch
        needed_milestone_types = Set.new

        profiles.each do |participant_profile|
          profile_declaration_types = declaration_types.dup

          # Filter out existing declaration types
          existing_types = participant_profile.participant_declarations.pluck(:declaration_type)
          profile_declaration_types.reject! { |type| type.in?(existing_types) }

          # Filter based on mentor/schedule conditions
          if participant_profile.mentor? && schedule.cohort.mentor_funding?
            profile_declaration_types.reject! { |type| type.match?(/retained|extended/) }
          end

          unless schedule.schedule_identifier.match?(/extended/)
            profile_declaration_types.reject! { |type| type.match?(/extended/) }
          end

          # Add needed milestone types to the set
          profile_declaration_types.each do |declaration_type|
            needed_milestone_types.add(declaration_type)
          end
        end

        # Create all needed milestones in a single transaction
        if needed_milestone_types.any?
          ActiveRecord::Base.transaction do
            needed_milestone_types.each do |declaration_type|
              next if schedule.milestones.exists?(declaration_type:)

              FactoryBot.create(
                :milestone,
                schedule:,
                declaration_type:,
                start_date: 1.day.ago,
              )
            end
          end
        end

        # Load all milestones for this schedule to avoid repeated queries
        schedule_milestones = schedule.milestones.index_by(&:declaration_type)

        # Process declarations for each profile
        profiles.each do |participant_profile|
          # Determine valid states for this profile
          profile_states = states.dup
          fundable_states = %w[payable paid awaiting_clawback clawed_back]

          unless participant_profile.fundable?
            profile_states.reject! { |state| state.in?(fundable_states) }
          end

          # Filter declaration types for this profile
          profile_declaration_types = declaration_types.dup
          existing_types = participant_profile.participant_declarations.pluck(:declaration_type)
          profile_declaration_types.reject! { |type| type.in?(existing_types) }

          if participant_profile.mentor? && schedule.cohort.mentor_funding?
            profile_declaration_types.reject! { |type| type.match?(/retained|extended/) }
          end

          unless schedule.schedule_identifier.match?(/extended/)
            profile_declaration_types.reject! { |type| type.match?(/extended/) }
          end

          # Prepare declarations to create
          declarations_to_create = []

          profile_declaration_types.each do |declaration_type|
            # Keep creating declarations with a 50% chance
            break unless Faker::Boolean.boolean(true_ratio: 0.5)

            # Get milestone for this declaration type
            milestone = schedule_milestones[declaration_type]
            next unless milestone # Skip if no milestone found

            # Determine state for this declaration
            state = profile_states.sample

            # Add to declarations to create
            declarations_to_create << {
              declaration_type:,
              participant_profile:,
              cpd_lead_provider:,
              cohort: schedule.cohort,
              milestone_date: milestone.start_date,
              state:,
              profile_type: participant_profile.ect? ? :ect : :mentor,
            }
          end

          # Create declarations in a single transaction
          next unless declarations_to_create.any?

          ActiveRecord::Base.transaction do
            declarations_to_create.each do |declaration_data|
              milestone_date = declaration_data.delete(:milestone_date)
              profile_type = declaration_data.delete(:profile_type)
              state = declaration_data.delete(:state)

              # Time travel once per declaration
              travel_to milestone_date do
                # Create declaration of correct type
                factory_name = "#{profile_type}_participant_declaration"
                FactoryBot.create(factory_name, state, **declaration_data)
              end
            end
          end
        end
      end
    end
  end
end
