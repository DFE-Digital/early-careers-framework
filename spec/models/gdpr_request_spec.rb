# frozen_string_literal: true

require "rails_helper"

RSpec.describe GDPRRequest, type: :model do
  it { is_expected.to belong_to(:cpd_lead_provider) }
  it { is_expected.to belong_to(:teacher_profile) }

  it "enables paper trail" do
    is_expected.to be_versioned
  end

  it "can be created" do
    cpd_lead_provider = FactoryBot.create(:seed_cpd_lead_provider)
    teacher_profile = FactoryBot.create(:seed_teacher_profile, :with_user)

    expect {
      GDPRRequest.create(cpd_lead_provider:, teacher_profile:, reason: :restrict_processing)
    }.to change { GDPRRequest.count }.by(1)
  end
end
