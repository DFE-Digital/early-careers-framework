# frozen_string_literal: true

RSpec.shared_examples "a started participant declaration service" do
  it_behaves_like "a participant declaration service"

  context "when including evidence_held" do
    it "ignores the extra parameter" do
      params = given_params.merge(evidence_held: "self-study-material-completed")
      expect { described_class.call(params: params) }.to change { ParticipantDeclaration.count }.by(1)
      expect(ParticipantDeclaration.order(created_at: :desc).first.evidence_held).to be_nil
    end
  end
end
