# frozen_string_literal: true

RSpec.describe DeliveryPartners::Participants::TableRow, type: :component do
  let(:school) { create(:school) }
  let(:school_cohort) { create(:school_cohort, school:) }
  let(:delivery_partner) { create(:delivery_partner) }
  let(:partnership) do
    create(
      :partnership,
      school:,
      delivery_partner:,
      challenged_at: nil,
      challenge_reason: nil,
      pending: false,
    )
  end
  let(:induction_programme) do
    induction_programme = create(:induction_programme, :fip, school_cohort:, partnership:)
    school_cohort.update!(default_induction_programme: induction_programme)
    induction_programme
  end

  let!(:induction_record) { create :induction_record, participant_profile:, induction_programme: }

  let(:component) { described_class.new participant_profile:, delivery_partner: }

  subject { render_inline(component) }

  context "when the participant profile is for a ECT" do
    let(:participant_profile) { create :ect_participant_profile, school_cohort: }

    it { is_expected.to have_text("Early career teacher") }
  end

  context "when the participant profile is for a Mentor" do
    let(:participant_profile) { create(:mentor_participant_profile, school_cohort:) }

    it { is_expected.to have_text("Mentor") }
  end

  context "when the participant profile is for a Mentor and Induction Tutor" do
    let(:participant_profile) { create(:mentor_participant_profile, school_cohort:) }
    let(:induction_coordinator_profile) { create(:induction_coordinator_profile, user: participant_profile.user) }

    it { is_expected.to have_text("Mentor") }
  end
end
