# frozen_string_literal: true

require "rails_helper"

RSpec.describe NPQContract do
  it { is_expected.to belong_to(:cohort) }

  describe "associations" do
    it { is_expected.to belong_to(:npq_lead_provider) }
    it { is_expected.to belong_to(:cohort) }
    it { is_expected.to belong_to(:npq_course).with_primary_key("identifier").with_foreign_key("course_identifier") }
  end

  describe "validations" do
    it { is_expected.to validate_numericality_of(:number_of_payment_periods).is_greater_than_or_equal_to(0).only_integer }
    it { is_expected.to validate_numericality_of(:output_payment_percentage).is_greater_than_or_equal_to(0).only_integer }
    it { is_expected.to validate_numericality_of(:service_fee_installments).is_greater_than_or_equal_to(0).only_integer }
    it { is_expected.to validate_numericality_of(:service_fee_percentage).is_greater_than_or_equal_to(0).only_integer }
    it { is_expected.to validate_numericality_of(:per_participant).is_greater_than(0) }
    it { is_expected.to validate_numericality_of(:recruitment_target).is_greater_than(0).only_integer }
    it { is_expected.to validate_numericality_of(:funding_cap).is_greater_than_or_equal_to(0).only_integer.allow_nil }
  end
end
