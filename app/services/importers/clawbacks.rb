# frozen_string_literal: true

# Consumes a csv of declaration ids
# Will create a clawback statement line item
# and attach to relevant statement

module Importers
  class Clawbacks
    attr_reader :path_to_csv, :errors

    def initialize(path_to_csv:)
      @path_to_csv = path_to_csv
      @errors = []
    end

    def call
      check_headers

      rows.each do |row|
        participant_declaration = ParticipantDeclaration.find_by(id: row["declaration_id"])

        if participant_declaration.nil?
          errors << "no declaration found with id: #{row['declaration_id']}"

          next
        end

        service = Finance::ClawbackDeclaration.new(participant_declaration:)

        begin
          service.call
        rescue StandardError => e
          errors << "declaration #{row['declaration_id']} has the following errors: #{e}"
        end

        if service.errors.any?
          errors << "declaration #{row['declaration_id']} has the following issues: #{service.errors.full_messages.join(', ')}"
        end
      end
    end

  private

    def check_headers
      unless rows.headers == %w[declaration_id]
        raise NameError, "Invalid headers"
      end
    end

    def rows
      @rows ||= CSV.read(path_to_csv, headers: true)
    end
  end
end
