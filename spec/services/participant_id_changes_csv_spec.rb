# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantIdChangesCsv do
  let(:cohort) { Cohort.current || create(:cohort, :current) }
  let(:npq_course) { create(:npq_course, identifier: "npq-senior-leadership") }

  let(:cpd_lead_provider1) { create(:cpd_lead_provider, :with_lead_provider, :with_npq_lead_provider) }
  let(:cpd_lead_provider2) { create(:cpd_lead_provider, :with_lead_provider, :with_npq_lead_provider) }

  # Create User1
  let(:lead_provider1) { cpd_lead_provider1.lead_provider }
  let(:partnership1) { create(:partnership, lead_provider: lead_provider1, cohort:) }
  let(:induction_programme) { create(:induction_programme, :fip, partnership: partnership1) }

  let(:participant_profile1) { create(:ect_participant_profile) }
  let(:induction_record1) { create(:induction_record, induction_programme:, participant_profile: participant_profile1) }
  let(:user1) { induction_record1.user }

  let!(:participant_id_change1) { create(:participant_id_change, to_participant: user1, user: user1, created_at: 1.day.ago) }

  # Create User2
  let(:lead_provider2) { cpd_lead_provider2.lead_provider }
  let(:partnership2) { create(:partnership, lead_provider: lead_provider2, cohort:) }
  let(:induction_programme2) { create(:induction_programme, :fip, partnership: partnership2) }

  let(:participant_profile2) { create(:ect_participant_profile) }
  let(:induction_record2) { create(:induction_record, induction_programme: induction_programme2, participant_profile: participant_profile2) }
  let(:user2) { induction_record2.user }

  let!(:participant_id_change2) { create(:participant_id_change, to_participant: user2, user: user2, created_at: 2.months.ago) }

  # Create User3
  let(:npq_lead_provider1) { cpd_lead_provider1.npq_lead_provider }
  let(:participant_profile3) { create(:npq_participant_profile, npq_lead_provider: npq_lead_provider1, npq_course:) }
  let(:user3) { participant_profile3.user }

  let!(:participant_id_change3) { create(:participant_id_change, to_participant: user3, user: user3, created_at: 5.days.ago) }

  # Create User4
  let(:npq_lead_provider2) { cpd_lead_provider2.npq_lead_provider }
  let(:participant_profile4) { create(:npq_participant_profile, npq_lead_provider: npq_lead_provider2, npq_course:) }
  let(:user4) { participant_profile4.user }

  let!(:participant_id_change4) { create(:participant_id_change, to_participant: user4, user: user4, created_at: 2.months.ago) }

  it "should return participant_id_changes for lead_provider1 only" do
    result = described_class.call(cpd_lead_provider: cpd_lead_provider1)
    parsed_result = CSV.parse(result).to_a

    expect(parsed_result.size).to eql(3)

    expect(parsed_result[0][0]).to eql("participant_id")
    expect(parsed_result[0][1]).to eql("from_participant_id")
    expect(parsed_result[0][2]).to eql("to_participant_id")
    expect(parsed_result[0][3]).to eql("changed_at")

    expect(parsed_result[1][0]).to eql(user3.id)
    expect(parsed_result[1][1]).to eql(participant_id_change3.from_participant_id)
    expect(parsed_result[1][2]).to eql(participant_id_change3.to_participant_id)
    expect(parsed_result[1][3]).to eql(participant_id_change3.created_at.rfc3339)

    expect(parsed_result[2][0]).to eql(user1.id)
    expect(parsed_result[2][1]).to eql(participant_id_change1.from_participant_id)
    expect(parsed_result[2][2]).to eql(participant_id_change1.to_participant_id)
    expect(parsed_result[2][3]).to eql(participant_id_change1.created_at.rfc3339)
  end

  it "should not return participant_id_changes older than 30 days" do
    result = described_class.call(cpd_lead_provider: cpd_lead_provider2)
    parsed_result = CSV.parse(result).to_a

    expect(parsed_result.size).to eql(1)

    expect(parsed_result[0][0]).to eql("participant_id")
    expect(parsed_result[0][1]).to eql("from_participant_id")
    expect(parsed_result[0][2]).to eql("to_participant_id")
    expect(parsed_result[0][3]).to eql("changed_at")
  end
end
