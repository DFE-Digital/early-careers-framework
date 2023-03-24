# frozen_string_literal: true

RSpec.describe Partnerships::Challenge do
  describe ".call" do
    let(:school) { create :school }
    let(:cohort) { create :cohort, :current }
    let!(:school_cohort) { create :school_cohort, school:, cohort: }
    let(:lead_provider) { create :lead_provider }
    let!(:lead_provider_profiles) { create_list(:lead_provider_profile, rand(2..3), lead_provider:) }
    let(:partnership) { create :partnership, school:, lead_provider:, cohort: }
    let(:challenge_reason) { Partnership.challenge_reasons.values.sample }
    let(:notify_provider) { true }

    subject(:service_call) { described_class.call(partnership:, challenge_reason:, notify_provider:) }

    it "marks given partnership as challenged" do
      service_call
      expect(partnership).to be_challenged
    end

    it "sets the challenge reason" do
      service_call
      expect(partnership.challenge_reason).to eq challenge_reason
    end

    it "sets the challenged_at time" do
      service_call
      expect(partnership.challenged_at).to be_within(1.second).of(Time.zone.now)
    end

    context "when challenge reason is invalid" do
      let(:challenge_reason) { "banana" }

      it "raises an error" do
        expect {
          service_call
        }.to raise_error ArgumentError
      end
    end

    context "when challenge reason is blank" do
      let(:challenge_reason) { nil }

      it "raises an error" do
        expect {
          service_call
        }.to raise_error ArgumentError
      end
    end

    it "updates the school cohorts" do
      expect { service_call }.to change { school_cohort.reload.updated_at }
    end

    it "sets the event log data" do
      service_call
      created_event = partnership.event_logs.order(created_at: :desc).first
      expect(created_event.event).to eql "challenged"
      expect(created_event.data["reason"]).to eql challenge_reason
    end

    it "schedules partnership challenged emails" do
      notify_all_lead_providers = lead_provider_profiles.map do |lp_profile|
        have_enqueued_mail(LeadProviderMailer, :partnership_challenged_email)
          .with(
            user: lp_profile.user,
            partnership:,
          )
      end
      notify_all_lead_providers = notify_all_lead_providers.inject do |expectations, expectation|
        expectations.and expectation
      end

      expect { service_call }.to notify_all_lead_providers
    end

    context "when notify_provider is false" do
      let(:notify_provider) { false }

      it "does not schedule partnership challenged emails" do
        expect { service_call }.not_to have_enqueued_mail(LeadProviderMailer, :partnership_challenged_email)
      end
    end

    context "when an error occurs updating the partnership" do
      before do
        allow(partnership).to receive(:no_ects?).and_raise(ActiveRecord::StatementInvalid)
      end

      it "raises an error and does not schedule partnership challenged emails" do
        expect { service_call }.to raise_error ActiveRecord::StatementInvalid
      end
    end

    context "when the challenge reason is no ECTs this year" do
      let(:challenge_reason) { "no_ects" }

      before do
        school_cohort.full_induction_programme!
      end

      it "sets the schools programme choice to reflect no ECTs" do
        expect { service_call }.to change { school_cohort.reload.induction_programme_choice }.to "no_early_career_teachers"
      end

      it "opts the school out of updates" do
        expect { service_call }.to change { school_cohort.reload.opt_out_of_updates }.to true
      end
    end
  end
end
