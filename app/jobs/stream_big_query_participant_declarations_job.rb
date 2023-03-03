# frozen_string_literal: true

class StreamBigQueryParticipantDeclarationsJob < ApplicationJob
  queue_as :big_query

  # Streams every attribute of a participant declarations (plus the lead provider name) that was
  # updated during the previous hour.
  def perform
    bigquery = Google::Cloud::Bigquery.new
    dataset = bigquery.dataset "provider_declarations", skip_lookup: true
    table = dataset.table "participant_declarations_#{Rails.env.downcase}"

    return if table.nil?

    ParticipantDeclaration
      .where(updated_at: 1.hour.ago.beginning_of_hour..1.hour.ago.end_of_hour)
      .find_in_batches do |declarations|
        rows = declarations.map do |participant_declaration|
          participant_declaration.attributes.merge(
            "cpd_lead_provider_name" => participant_declaration.cpd_lead_provider.name,
          )
        end
        table.insert(rows, ignore_unknown: true) if rows.any?
      end
  end
end
