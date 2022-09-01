# frozen_string_literal: true

require "rails_helper"

RSpec.describe InviteEcts do
  subject(:invite_ects) { described_class.new }
  let!(:cohort) { create(:cohort, :next) }

  let!(:school) { create(:school) }
  let!(:school_cohort) { create(:school_cohort, cohort: create(:cohort, start_year: cohort.start_year - 1)) }

  let!(:induction_coordinator_profile) { create(:induction_coordinator_profile, schools: [school]) }

  before(:all) do
    FeatureFlag.activate(:multiple_cohorts)
    RSpec::Mocks.configuration.verify_partial_doubles = false
  end

  before(:each) do
    allow_any_instance_of(Mail::TestMailer).to receive_message_chain(:response, :id) { "notify_id" }
  end

  after(:all) do
    FeatureFlag.deactivate(:multiple_cohorts)
    RSpec::Mocks.configuration.verify_partial_doubles = true
  end

  describe "#preterm_reminder" do
    it "sends the nomination email" do
      expect(ParticipantMailer).to receive(:preterm_reminder_unconfirmed_for_2022).with(
        hash_including(induction_coordinator_profile:),
      ).and_call_original

      invite_ects.preterm_reminder
    end

    context "with an induction profile that has already received the email" do
      before do
        create(:email, associated_with: [induction_coordinator_profile], tags: %w[preterm_reminder_unconfirmed_for_2022])
      end

      it "does not send the email again" do
        expect(ParticipantMailer).to receive(:preterm_reminder_unconfirmed_for_2022).never

        invite_ects.preterm_reminder
      end
    end

    context "where the school is a childrens centre" do
      before do
        school.update!(school_type_code: GiasTypes::NO_INVITATIONS_TYPE_CODES.sample)
      end

      it "does not send the email again" do
        expect(ParticipantMailer).to receive(:preterm_reminder_unconfirmed_for_2022).never

        invite_ects.preterm_reminder
      end
    end

    context "where the school has already chosen a programme" do
      before { create :school_cohort, school:, cohort: }

      it "does not send the email again" do
        expect(ParticipantMailer).to receive(:preterm_reminder_unconfirmed_for_2022).never

        invite_ects.preterm_reminder
      end
    end
  end
end
