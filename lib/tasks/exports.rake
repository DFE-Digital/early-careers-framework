# frozen_string_literal: true

namespace :exports do
  desc "Create CSV of ECF M3 assurance extract - CPDLP-1229"
  task ecf_m3_assurance_extract: :environment do
    headers = [
      "Participant ID",
      "Participant Name",
      "TRN",
      "Type",
      "Mentor Profile ID", # (i.e. the associated mentor id for the given participant id)
      "Schedule",
      "Eligible for Funding",
      "School URN",
      "School Name",
      "Sparsity Uplift", # (IF true = "1", IF false = "0")
      "PP Uplift", # (IF true = "1", IF false = "0")
      "Sparsity and PP", # (IF sparsity uplift + PP uplift = "2", THEN "1", ELSE sparsity uplift + PP uplift)
      "Lead Provider Name",
      "Delivery Partner Name",
      "Training Status",
      "Training Status Reason",
      "Declaration ID",
      "Declaration Type",
      "Declaration Date",
      "Declaration State",
      "Declaration Created At",
    ]

    file_path = Rails.root.join("tmp", "payable_declarations_#{Time.zone.today.iso8601}.csv").to_s

    CSV.open(file_path, "w", headers: true) do |csv|
      csv << headers
      puts ">>> Initializing Report"

      ParticipantDeclaration::ECF.find_each do |pd|
        sparsity_uplift = (pd.participant_profile.sparsity_uplift ? 1 : 0)
        pupil_premium_uplift = (pd.participant_profile.pupil_premium_uplift ? 1 : 0)
        sparsity_and_pp_uplift = ((sparsity_uplift + pupil_premium_uplift) == 2 ? 1 : 0)

        if !pd.participant_profile.mentor? && pd.participant_profile.mentor_profile
          mentor_profile_id = pd.participant_profile&.mentor_profile&.user&.id
        end

        csv << [
          pd.user.id,
          pd.user.full_name,
          pd.participant_profile.teacher_profile.trn,
          pd.participant_profile.type,
          mentor_profile_id,
          pd.participant_profile.schedule.name,
          pd.participant_profile&.ecf_participant_eligibility&.status,
          pd.participant_profile.school.urn,
          pd.participant_profile.school.name,
          sparsity_uplift,
          pupil_premium_uplift,
          sparsity_and_pp_uplift,
          pd.cpd_lead_provider.name,
          pd.participant_profile.school.active_partnerships.find_by(cohort: Cohort.current)&.delivery_partner&.name,
          pd.participant_profile.training_status,
          pd.participant_profile.participant_profile_states.where(state: "withdrawn")&.first&.reason,
          pd.id,
          pd.declaration_type,
          pd.declaration_date.strftime("%d/%m/%Y"),
          pd.state,
          pd.created_at.strftime("%d/%m/%Y"),
        ]
      end

      puts ">>> Report complete: #{file_path}"

      ## To scp file from prod to local:
      # GUID=$(cf app ecf-production --guid)
      # cf ssh-code ## use this as scp password
      # scp -P 2222 -o StrictHostKeyChecking=no -o User=cf:${GUID}/0 ssh.london.cloud.service.gov.uk:/app/payable_declarations.csv .
    end
  end

  desc "ECF declarations which have not moved from the submitted state (post duplicates) - [CPDLP-2032]"
  task ecf_declarations_not_moved_from_submitted_extract: :environment do
    headers = [
      "Participant ID",
      "Participant Name",
      "TRN",
      "Type",
      "Schedule",
      "Eligible for Funding",
      "School URN",
      "School Name",
      "Lead Provider Name",
      "Delivery Partner Name",
      "Training Status",
      "Training Status Reason",
      "Participant Cohort",
      "Declaration ID",
      "Declaration Type",
      "Declaration Date",
      "Declaration State",
      "Declaration Created At",
      "Declaration Cohort",
    ]

    file_path = Rails.root.join("tmp", "submitted_declarations_#{Time.zone.today.iso8601}.csv").to_s

    CSV.open(file_path, "w", headers: true) do |csv|
      csv << headers
      puts ">>> Initializing Report"

      ParticipantDeclaration::ECF.submitted.find_in_batches do |pds|
        pds.map do |pd|
          pd.participant_profile
          cpd_lead_provider = pd.cpd_lead_provider

          relevant_induction_record = Induction::FindBy.call(
            participant_profile: pd.participant_profile,
            lead_provider: cpd_lead_provider.lead_provider,
            date_range: ..pd.declaration_date,
          )

          next unless pd.participant_profile&.eligible?

          csv << [
            pd.user.id,
            pd.user.full_name,
            pd.participant_profile.teacher_profile.trn,
            pd.participant_profile.type,
            pd.participant_profile.schedule.name,
            pd.participant_profile&.ecf_participant_eligibility&.status,
            pd.participant_profile.school.urn,
            pd.participant_profile.school.name,
            cpd_lead_provider.name,
            pd.participant_profile.school.active_partnerships.find_by(cohort: Cohort.current)&.delivery_partner&.name,
            pd.participant_profile.training_status,
            pd.participant_profile.participant_profile_states.where(state: "withdrawn")&.first&.reason,
            pd.participant_profile.schedule_for(cpd_lead_provider:)&.cohort&.start_year&.to_s,
            pd.id,
            pd.declaration_type,
            pd.declaration_date.strftime("%d/%m/%Y"),
            pd.state,
            pd.created_at.strftime("%d/%m/%Y"),
            relevant_induction_record&.cohort&.start_year&.to_s,
          ]

          # Where the participant is eligible and the declaration is submitted, we have changed the state to eligible and attached to the next open statement as a line item
          # ParticipantDeclaration.transaction do
          #   pd.make_eligible!
          #   Finance::DeclarationStatementAttacher.new(pd).call
          # end
        end
      end

      puts ">>> Report complete: #{file_path}"
    end
  end
end
