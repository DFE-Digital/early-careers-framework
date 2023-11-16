# frozen_string_literal: true

FactoryBot.define do
  factory :participant_declaration do
    declaration_type { "started" }

    declaration_date do
      participant_profile.schedule.milestones.find_by!(declaration_type:).start_date
    end

    transient do
      cohort         { Cohort.current || create(:cohort, :current) }
      profile_traits { [] }
      uplifts        { [] }
      has_passed     { false }
    end

    factory :ecf_participant_declaration, class: "ParticipantDeclaration::ECF" do
      cpd_lead_provider { create(:cpd_lead_provider, :with_lead_provider) }

      factory :ect_participant_declaration, class: "ParticipantDeclaration::ECF" do
        course_identifier { "ecf-induction" }
        participant_profile { create(:ect, *uplifts, *profile_traits, lead_provider: cpd_lead_provider.lead_provider, cohort:) }
      end

      factory :mentor_participant_declaration, class: "ParticipantDeclaration::ECF" do
        course_identifier { "ecf-mentor" }
        participant_profile { create(:mentor, *uplifts, *profile_traits, lead_provider: cpd_lead_provider.lead_provider, cohort:) }
      end
    end

    factory :npq_participant_declaration, class: "ParticipantDeclaration::NPQ" do
      transient do
        npq_course { create(:npq_course) }
        school_urn {}
        cohort     { Cohort.current || create(:cohort, :current) }
      end
      cpd_lead_provider   { create(:cpd_lead_provider, :with_npq_lead_provider) }
      participant_profile { create(:npq_application, :accepted, *profile_traits, npq_lead_provider: cpd_lead_provider.npq_lead_provider, npq_course:, school_urn:, cohort:).profile }
      course_identifier   { participant_profile.npq_course.identifier }
    end

    initialize_with do
      participant_id = participant_profile.ecf? ? participant_profile.participant_identity.user_id : participant_profile.npq_application.participant_identity.user_id

      params = {
        participant_id:,
        course_identifier:,
        declaration_date: declaration_date.rfc3339,
        declaration_type:,
        cpd_lead_provider:,
        has_passed:,
      }

      params[:evidence_held] = "other" if declaration_type != "started"

      if participant_profile.is_a?(ParticipantProfile::NPQ)
        opts = {
          npq_lead_provider: cpd_lead_provider.npq_lead_provider,
          cohort: participant_profile.npq_application.cohort,
          npq_course: participant_profile.npq_application.npq_course,
          version: "1.0",
        }
        NPQContract.find_by(opts) || create(:npq_contract, opts)
      end

      service = RecordDeclaration.new(params)
      raise ArgumentError, service.errors.full_messages unless service.valid?

      if participant_profile.is_a?(ParticipantProfile::NPQ) && participant_profile.fundable?
        cohort = participant_profile.npq_application.cohort
        next_output_fee_statement = cpd_lead_provider.npq_lead_provider.next_output_fee_statement(cohort)
        create(:npq_statement, :next_output_fee, cpd_lead_provider:, cohort:) unless next_output_fee_statement
      end

      if participant_profile.is_a?(ParticipantProfile::ECF) && participant_profile.fundable?
        cohort = participant_profile.current_induction_record.schedule.cohort
        next_output_fee_statement = cpd_lead_provider.lead_provider.next_output_fee_statement(cohort)
        create(:ecf_statement, :next_output_fee, cpd_lead_provider:, cohort:) unless next_output_fee_statement
      end

      service.call
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
        factory = previous_statement.is_a?(Finance::Statement::ECF) ? :ecf_statement : :npq_statement
        create(
          factory, :next_output_fee,
          deadline_date: previous_statement.deadline_date + 1.month,
          payment_date: previous_statement.payment_date,
          cpd_lead_provider: previous_statement.cpd_lead_provider
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
