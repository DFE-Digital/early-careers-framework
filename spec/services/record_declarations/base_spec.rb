require "rails_helper"

RSpec.describe RecordDeclarations::Base do
  let(:user)              { create(:user, :early_career_teacher) }
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:declaration_date)  { Time.zone.parse("2021-11-02") }
  let(:declaration_type)  { 'started' }
  let(:params) do
    {
      participant_id: user.id,
      course_identifier: "ecf-induction",
      cpd_lead_provider: cpd_lead_provider,
      declaration_date: declaration_date,
      declaration_type: declaration_type,
    }
  end

  describe "#call" do
    context "when no duplicate participant exists" do
      context "when the participant is fundable" do
        it "transitions the declaration to eligible" do
          expect {
            described_class.call(params: params)
          }.to change(participant_declaration).from()
        end
      end
      context "when the participant is not fundable" do
        it "transitions the declaration to submitted"
      end
    end

    context "when a duplicated participant exist" do
      it "transitions the declaration to ineligible"
    end
  end
end
