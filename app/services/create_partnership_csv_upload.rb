# frozen_string_literal: true

class CreatePartnershipCsvUpload
  attr_reader :csv_file, :cohort_id, :lead_provider_id, :delivery_partner_id

  def initialize(csv_file:, cohort_id:, lead_provider_id:, delivery_partner_id:)
    @csv_file = csv_file
    @cohort_id = cohort_id
    @lead_provider_id = lead_provider_id
    @delivery_partner_id = delivery_partner_id
  end

  def call
    PartnershipCsvUpload.create!(
      cohort_id:,
      lead_provider_id:,
      delivery_partner_id:,
      uploaded_urns:,
    )
  end

private

  def uploaded_urns
    clean_uploaded_lines(strip_bom(csv_file.read).scrub.lines(chomp: true))
  end

  def clean_uploaded_lines(lines)
    lines.flat_map { |line| line.split(",").reject(&:blank?).map(&:squish) }
  end

  def strip_bom(string)
    string.force_encoding("UTF-8").gsub(/\xEF\xBB\xBF/, "")
  end
end
