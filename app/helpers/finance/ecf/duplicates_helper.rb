# frozen_string_literal: true

module Finance
  module ECF
    module DuplicatesHelper
      def tag_for(participant_profile)
        if participant_profile.primary_profile?
          govuk_tag(text: "primary", colour: "green")
        else
          govuk_tag(text: "duplicate", colour: "grey")
        end
      end

      def header_row_for(row)
        row.cell(header: true, text: "Profile type")
        row.cell(header: true, text: "Participant ID")
        row.cell(header: true, text: "Profile ID")
        row.cell(header: true, text: "TRN")
        row.cell(header: true, text: "Cohort")
        row.cell(header: true, text: "Schedule")
        row.cell(header: true, text: "Induction status")
        row.cell(header: true, text: "Training status")
        row.cell(header: true, text: "Lead Provider")
        row.cell(header: true, text: "School")
        row.cell(header: true, text: "Starts on")
        row.cell(header: true, text: "Ends on")
        row.cell(header: true, text: "Declaration count")
      end

      def row_for(row, participant_profile)
        row.cell { tag_for(participant_profile) }
        row.cell do
          participant_profile.participant_id
        end
        row.cell(text: participant_profile.id)
        row.cell(text: participant_profile.teacher_profile_trn.to_s)
        row.cell(text: participant_profile.cohort)
        row.cell(text: participant_profile.schedule_identifier)
        row.cell(text: participant_profile.induction_status)
        row.cell(text: participant_profile.training_status)
        row.cell(text: participant_profile.provider_name)
        row.cell(text: participant_profile.school_name)
        row.cell(text: participant_profile.start_date.to_fs(:govuk))
        row.cell(text: participant_profile.end_date&.to_fs(:govuk))
        row.cell(text: participant_profile.declaration_count)
      end

      def comparative_table_row_for(primary_profile:, duplicate_profile:, header:, row:, method:)
        primary_value = primary_profile.public_send(method)
        duplicate_value = duplicate_profile.public_send(method)
        classes = primary_value == duplicate_value ? [] : ["govuk-tag--red"]
        row.cell(header: true, text: header)
        row.cell(text: primary_value, classes:)
        row.cell(text: duplicate_value, classes:)
      end
    end
  end
end
