# frozen_string_literal: true

require "ecf_api_client/api"

class ECFApiClient
  class Participant
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :id
    attribute :full_name
    attribute :email
    attribute :email_validated
    attribute :teacher_reference_number
    attribute :teacher_reference_number_validated
    attribute :works_in_school
    attribute :employer_name
    attribute :employment_role
    attribute :school_urn
    attribute :school_ukprn
    attribute :headteacher_status
    attribute :eligible_for_funding, :boolean
    attribute :funding_choice
    attribute :status
    attribute :mentor_id
    attribute :participant_type
    attribute :cohort
    attribute :pupil_premium_uplift
    attribute :sparsity_uplift
    attribute :training_status
    attribute :schedule_identifier
    attribute :created_at
    attribute :updated_at

    def to_table
      [participant_type, id, email, eligible_for_funding, training_status, course_identifier, cohort, schedule_identifier]
    end

    def course_identifier
      participant_type == "ect" ? "ecf-induction" : "ecf-mentor"
    end

    def record_start_declaration(declaration_date: Date.new(2021, 9, 2))
      API.participant_declaration(
        participant_id: id,
        declaration_type: "started",
        declaration_date: declaration_date,
        course_identifier: course_identifier,
      )
    end

    def change_schedule(schedule_identifier, cohort: 2021)
      API.change_schedule(
        id: id,
        schedule_identifier: schedule_identifier,
        course_identifier: course_identifier,
        cohort: cohort,
      )
    end

    class << self
      def participants
        API.participants
      end

      def from(api)
        new(api.fetch("attributes").merge(id: api["id"]))
      end

      def display(rows)
        table = Terminal::Table.new do |t|
          t.headings = %w[participant_type id email eligible_for_funding training_status course_identifier cohort schedule_identifier]
          t.rows = rows.map(&:to_table)
        end
        $stdout.puts table
      end
    end
  end
end
