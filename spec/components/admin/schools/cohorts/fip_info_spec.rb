# frozen_string_literal: true

RSpec.describe Admin::Schools::Cohorts::FipInfo, type: :view_component do
  let(:school_cohort) { FactoryBot.create :school_cohort, :fip }
  let(:lead_provider) { FactoryBot.create :lead_provider }

  before do
    FactoryBot.create :partnership, school: school_cohort.school, cohort: school_cohort.cohort, lead_provider: lead_provider
  end

  component { described_class.new school_cohort: school_cohort }

  it { is_expected.to have_content "Use an approved training provider" }
  it { is_expected.to have_content lead_provider.name }
  it { is_expected.to have_content school_cohort.delivery_partner.name }
end
