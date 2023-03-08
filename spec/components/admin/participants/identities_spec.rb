# frozen_string_literal: true

RSpec.describe Admin::Participants::Identities, :with_default_schedules, type: :component do
  let(:component) { described_class.new identities: }

  context "when it's the original identity" do
    let(:identities) { build_list(:participant_identity, 1, :npq_origin) }
    let(:identity) { identities.first }

    it "renders all the required information and label it as 'Original'" do
      render_inline(component)

      expect(rendered_content).to include(
        "Original",
        identity.user_id,
        identity.external_identifier,
        identity.email,
        identity.origin,
      )
    end
  end

  context "with secondary identities" do
    let(:identities) { build_list(:participant_identity, 2, :npq_origin, :secondary) }

    it "renders info for all the identities and labels them as 'Additional'" do
      render_inline(component)

      identities.each do |identity|
        expect(rendered_content).to include(
          "Additional",
          identity.user_id,
          identity.external_identifier,
          identity.email,
          identity.origin,
        )
      end
    end
  end
end
