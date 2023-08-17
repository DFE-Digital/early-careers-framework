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
        row.with_cell(header: true, text: "Profile type")
        row.with_cell(header: true, text: "Participant ID")
        row.with_cell(header: true, text: "Profile ID")
        row.with_cell(header: true, text: "TRN")
        row.with_cell(header: true, text: "Cohort")
        row.with_cell(header: true, text: "Schedule")
        row.with_cell(header: true, text: "Induction status")
        row.with_cell(header: true, text: "Training status")
        row.with_cell(header: true, text: "Lead Provider")
        row.with_cell(header: true, text: "School")
        row.with_cell(header: true, text: "Starts on")
        row.with_cell(header: true, text: "Ends on")
        row.with_cell(header: true, text: "Declaration count")
      end

      def row_for(row, participant_profile)
        row.with_cell { tag_for(participant_profile) }
        row.with_cell do
          participant_profile.participant_id
        end
        row.with_cell(text: participant_profile.id)
        row.with_cell(text: participant_profile.teacher_profile_trn.to_s)
        row.with_cell(text: participant_profile.cohort)
        row.with_cell(text: participant_profile.schedule_identifier)
        row.with_cell(text: participant_profile.induction_status)
        row.with_cell(text: participant_profile.training_status)
        row.with_cell(text: participant_profile.provider_name)
        row.with_cell(text: participant_profile.school_name)
        row.with_cell(text: participant_profile.start_date.to_fs(:govuk))
        row.with_cell(text: participant_profile.end_date&.to_fs(:govuk))
        row.with_cell(text: participant_profile.declaration_count)
      end

      def comparative_table_row_for(primary_profile:, duplicate_profile:, header:, row:, method:)
        primary_value = primary_profile.public_send(method)
        duplicate_value = duplicate_profile.public_send(method)
        classes = primary_value == duplicate_value ? [] : ["govuk-tag--red"]
        row.with_cell(header: true, text: header)
        row.with_cell(text: primary_value, classes:)
        row.with_cell(text: duplicate_value, classes:)
      end
    end
  end
end
