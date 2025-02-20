# frozen_string_literal: true

FactoryBot.define do
  factory :participant_declaration do
    declaration_type { "started" }
    cohort { Cohort.current || create(:cohort, :current) }

    declaration_date do
      participant_profile.schedule.milestones.find_by!(declaration_type:).start_date
    end

    transient do
      profile_traits { [] }
      uplifts        { [] }
      has_passed     { false }
    end

    factory :ect_participant_declaration, class: ParticipantDeclaration::ECT do
      type { "ParticipantDeclaration::ECT" }
      cpd_lead_provider { create(:cpd_lead_provider, :with_lead_provider) }
      course_identifier { "ecf-induction" }
      participant_profile { create(:ect, *uplifts, *profile_traits, lead_provider: cpd_lead_provider.lead_provider, cohort:) }
    end

    factory :mentor_participant_declaration, class: ParticipantDeclaration::Mentor do
      type { "ParticipantDeclaration::Mentor" }
      cpd_lead_provider { create(:cpd_lead_provider, :with_lead_provider) }
      course_identifier { "ecf-mentor" }
      participant_profile { create(:mentor, *uplifts, *profile_traits, lead_provider: cpd_lead_provider.lead_provider, cohort:) }
    end

    initialize_with do
      participant_id = participant_profile.participant_identity.user_id

      params = {
        participant_id:,
        course_identifier:,
        declaration_date: declaration_date.rfc3339,
        declaration_type:,
        cpd_lead_provider:,
        has_passed:,
      }

      cohort = participant_profile.current_induction_record.schedule.cohort
      params[:evidence_held] = if cohort.detailed_evidence_types?
                                 case declaration_type
                                 when "started", "retained-1", "retained-3", "retained-4", "extended-1", "extended-2", "extended-3"
                                   "other"
                                 else
                                   "75-percent-engagement-met"
                                 end
                               elsif declaration_type != "started"
                                 "other"
                               end

      if participant_profile.is_a?(ParticipantProfile::ECF) && participant_profile.fundable?
        next_output_fee_statement = cpd_lead_provider.lead_provider.next_output_fee_statement(cohort)
        create(:ecf_statement, :next_output_fee, cpd_lead_provider:, cohort:) unless next_output_fee_statement
      end

      service = RecordDeclaration.new(params)
      raise ArgumentError, service.errors.full_messages unless service.valid?

      service.call
    end

    trait :submitted do
      state { :submitted }
    end

    trait :ineligible do
      state { :ineligible }
    end

    trait :eligible do
      profile_traits { [:eligible_for_funding] }
    end

    trait :extended do
      declaration_type { "extended-1" }
      profile_traits { %i[eligible_for_funding with_extended_schedule] }
    end

    trait :voided do
      after(:create) do |participant_declaration|
        VoidParticipantDeclaration.new(participant_declaration).call
        participant_declaration.reload
      end
    end

    trait :payable do
      eligible
      after(:create) do |participant_declaration|
        previous_statement = participant_declaration.statement_line_items.eligible.first.statement
        Statements::MarkAsPayable.new(previous_statement).call
        participant_declaration.reload
      end
    end

    trait :paid do
      payable
      after(:create) do |participant_declaration|
        previous_statement = participant_declaration.statement_line_items.payable.first.statement
        Statements::MarkAsPaid.new(previous_statement).call
        participant_declaration.reload
      end
    end

    trait :awaiting_clawback do
      paid
      after(:create) do |participant_declaration|
        previous_statement = participant_declaration.statement_line_items.paid.first.statement

        create(
          :ecf_statement, :next_output_fee,
          deadline_date: previous_statement.deadline_date + 1.month,
          payment_date: previous_statement.payment_date,
          cpd_lead_provider: previous_statement.cpd_lead_provider,
          cohort: participant_declaration.cohort
        )

        service = Finance::ClawbackDeclaration.new(participant_declaration)
        raise ArgumentError, service.errors.full_messages unless service.valid?

        service.call
        participant_declaration.reload
      end
    end

    trait :clawed_back do
      awaiting_clawback

      after(:create) do |participant_declaration|
        statement = participant_declaration.statement_line_items.awaiting_clawback.first.statement
        Statements::MarkAsPaid
          .new(statement)
          .call
        participant_declaration.reload
      end
    end
    transient do
      uplift { [] }
    end
  end
end
