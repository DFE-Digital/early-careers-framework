# frozen_string_literal: true

require "rails_helper"

RSpec.describe UpdateInductionTutorReminder do
  let(:school) { FactoryBot.create(:seed_school, :with_induction_coordinator) }

  describe "initialization" do
    it "can be initialized with just a school" do
      reminder = UpdateInductionTutorReminder.new(school)
      expect(reminder.school).to eql(school)
    end
  end

  describe "#send!" do
    let(:method_name) { :remind_to_update_school_induction_tutor_details }
    subject { UpdateInductionTutorReminder.new(school) }

    before do
      allow(SchoolMailer).to(receive(method_name).and_call_original)
    end

    it "calls SchoolMailer.remind_to_update_school_induction_tutor_details with the appropriate arguments" do
      subject.send!

      expect(SchoolMailer).to have_received(method_name).with(
        school:,
        sit_name: school.induction_tutor.full_name,
        nomination_link: subject.instance_variable_get(:@nomination_link),
      )
    end

    it "creates a nomination_email record" do
      expect { subject.send! }.to(change { NominationEmail.count }.by(1))
    end

    context "when an email has been sent recently" do
      before do
        allow(Rails.logger).to receive(:warn).with(any_args).and_return(true)
        Email.create!(tags: %i[remind_to_update_induction_tutor]).create_association_with(school)
      end

      it "only sends one email within the permitted timeframe" do
        result = subject.send!

        expect(result).to be(false)
        expect(Rails.logger).to have_received(:warn).with(/has been sent a nomination email reminder/)
      end
    end

    context "when there is no SIT" do
      before do
        allow(Rails.logger).to receive(:error).with(any_args).and_return(true)
      end

      let(:school) { FactoryBot.create(:seed_school) }

      it "logs there is no SIT and returns false" do
        result = subject.send!

        expect(result).to be(false)
        expect(Rails.logger).to have_received(:error).with(/no valid recipient/)
      end
    end

    context "when the school has no email addresses" do
      before do
        allow(Rails.logger).to receive(:warn).with(any_args).and_return(true)
      end

      let(:school) { FactoryBot.create(:seed_school, primary_contact_email: nil, secondary_contact_email: nil) }

      it "logs there is no SIT and returns false" do
        result = subject.send!

        expect(result).to be(false)
        expect(Rails.logger).to have_received(:warn).with(/no contact email addresses/)
      end
    end
  end
end
