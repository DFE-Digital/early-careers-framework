# frozen_string_literal: true

RSpec.describe AppropriateBodies::ChooseOrganisationForm, type: :model do
  subject(:form) { described_class.new(params) }

  let(:params) { { user:, appropriate_body_id: form_appropriate_body_id } }
  let(:form_appropriate_body_id) { nil }
  let(:user) { create(:user) }

  describe "#appropriate_body" do
    let!(:appropriate_body_profile) { create(:appropriate_body_profile, user:) }
    let(:form_appropriate_body_id) { appropriate_body_profile.appropriate_body.id }

    it "returns appropriate_body" do
      expect(form.appropriate_body).to eql(appropriate_body_profile.appropriate_body)
    end
  end

  describe "#only_one" do
    describe "one appropriate body" do
      let!(:appropriate_body_profile1) { create(:appropriate_body_profile, user:) }

      it "returns true" do
        expect(form.only_one).to be true
        expect(form.appropriate_body).to eql(appropriate_body_profile1.appropriate_body)
      end
    end

    describe "multiple appropriate bodies" do
      let!(:appropriate_body_profile1) { create(:appropriate_body_profile, user:) }
      let!(:appropriate_body_profile2) { create(:appropriate_body_profile, user:) }
      let!(:appropriate_body_profile3) { create(:appropriate_body_profile, user:) }

      it "returns false" do
        expect(form.only_one).to be false
      end
    end
  end

  describe "#appropriate_body_options" do
    let!(:appropriate_body_profile1) { create(:appropriate_body_profile, user:) }
    let!(:appropriate_body_profile2) { create(:appropriate_body_profile, user:) }
    let!(:appropriate_body_profile3) { create(:appropriate_body_profile, user:) }

    it "returns form options" do
      expect(form.appropriate_body_options).to include(
        appropriate_body_profile1.appropriate_body.id => appropriate_body_profile1.appropriate_body.name,
        appropriate_body_profile2.appropriate_body.id => appropriate_body_profile2.appropriate_body.name,
        appropriate_body_profile3.appropriate_body.id => appropriate_body_profile3.appropriate_body.name,
      )
    end
  end
end
