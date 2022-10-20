# frozen_string_literal: true

RSpec.describe Admin::Participants::Identities, :with_default_schedules, type: :view_component do
  component { described_class.new identities: }

  context "when it's the original identity" do
    let(:identities) { build_list(:participant_identity, 1, :npq_origin) }
    let(:identity) { identities.first }

    it "renders all the required information and label it as 'Original'" do
      expect(rendered).to have_contents(
        "Original",
        identity.user_id,
        identity.external_identifier,
        identity.email,
        identity.origin,
      )
    end
  end

  context "with transferred identities" do
    let(:identities) { build_list(:participant_identity, 2, :npq_origin, :transferred) }

    it "renders info for all the identities and labels them as 'Transferred'" do
      identities.each do |identity|
        expect(rendered).to have_contents(
          "Transferred",
          identity.user_id,
          identity.external_identifier,
          identity.email,
          identity.origin,
        )
      end
    end
  end
end
