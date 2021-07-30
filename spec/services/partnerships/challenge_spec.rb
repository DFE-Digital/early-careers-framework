# frozen_string_literal: true

RSpec.describe Partnerships::Challenge do
  describe "#call" do
    let(:school) { create :school }
    let(:cohort) { create :cohort, :current }
    let!(:school_cohort) { create :school_cohort, school: school, cohort: cohort }
    let(:lead_provider) { create :lead_provider }
    let!(:lead_provider_profiles) { create_list(:lead_provider_profile, rand(2..3), lead_provider: lead_provider) }
    let(:partnership) { create :partnership, school: school, lead_provider: lead_provider, cohort: cohort }
    let(:reason) { Partnership.challenge_reasons.values.sample }

    subject { described_class.new(partnership, reason) }

    it "marks given partnership as challenged" do
      expect { subject.call }.to change { partnership.reload.challenged? }.to true
    end

    it "sets the correct challenge reason" do
      expect { subject.call }.to change { partnership.reload.challenge_reason }.to reason
      created_event = partnership.event_logs.order(created_at: :desc).first
      expect(created_event.event).to eql "challenged"
      expect(created_event.data["reason"]).to eql reason
    end

    it "stores :challenged event in the partnership event log" do
      expect { subject.call }.to change { partnership.event_logs.map(&:event) }.by %w[challenged]
    end

    it "schedules partnership challenged emails" do
      subject.call

      lead_provider_profiles.each do |lp_profile|
        expect(LeadProviderMailer).to delay_email_delivery_of(:partnership_challenged_email)
                                        .with(user: lp_profile.user, partnership: partnership)
      end
    end

    context "when the challenge reason is no ECTs this year" do
      let(:reason) { "no_ects" }

      before do
        school_cohort.full_induction_programme!
      end

      it "sets the schools programme choice to reflect no ECTs" do
        expect { subject.call }.to change { school_cohort.reload.induction_programme_choice }.to "no_early_career_teachers"
      end

      it "opts the school out of updates" do
        expect { subject.call }.to change { school_cohort.reload.opt_out_of_updates }.to true
      end
    end
  end
end
