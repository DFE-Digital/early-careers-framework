# frozen_string_literal: true

require "rails_helper"

RSpec.describe InviteEcts do
  subject(:invite_ects) { described_class.new }
  let!(:cohort) { create(:cohort, :current) }

  let!(:school) { create(:school) }
  let!(:school_cohort) { create(:school_cohort, school:, cohort: create(:cohort, start_year: cohort.start_year - 1)) }

  let!(:induction_coordinator_profile) { create(:induction_coordinator_profile, schools: [school]) }

  before(:all) do
    RSpec::Mocks.configuration.verify_partial_doubles = false
  end

  before(:each) do
    allow_any_instance_of(Mail::TestMailer).to receive_message_chain(:response, :id) { "notify_id" }
  end

  after(:all) do
    RSpec::Mocks.configuration.verify_partial_doubles = true
  end

  describe "#preterm_reminder" do
    it "sends the nomination email" do
      expect { invite_ects.preterm_reminder }
        .to have_enqueued_mail(ParticipantMailer, :preterm_reminder_unconfirmed_for_2022)
          .with(
            params: {
              induction_coordinator_profile:,
            },
            args: [],
          )
    end

    context "with an induction profile that has already received the email" do
      before do
        create(:email, associated_with: [induction_coordinator_profile], tags: %w[preterm_reminder_unconfirmed_for_2022])
      end

      it "does not send the email again" do
        expect { invite_ects.preterm_reminder }
          .not_to have_enqueued_mail(ParticipantMailer, :preterm_reminder_unconfirmed_for_2022)
      end
    end

    context "where the school is a childrens centre" do
      before do
        school.update!(school_type_code: GiasTypes::NO_INVITATIONS_TYPE_CODES.sample)
      end

      it "does not send the email again" do
        expect { invite_ects.preterm_reminder }
          .not_to have_enqueued_mail(ParticipantMailer, :preterm_reminder_unconfirmed_for_2022)
      end
    end

    context "where the school has already chosen a programme" do
      before { create :school_cohort, school:, cohort: }

      it "does not send the email again" do
        expect { invite_ects.preterm_reminder }
          .not_to have_enqueued_mail(ParticipantMailer, :preterm_reminder_unconfirmed_for_2022)
      end
    end
  end
end
