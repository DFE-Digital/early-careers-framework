# frozen_string_literal: true

require "rails_helper"

RSpec.describe NominateInductionTutorForm, type: :model do
  let(:nomination_email) { create(:nomination_email) }
  let(:school) { nomination_email.school }
  let(:full_name) { Faker::Name.name }
  let(:email) { Faker::Internet.email }

  describe "validations" do
    it { is_expected.to validate_presence_of(:email).with_message("Enter an email address").on(%i[email]) }
    it { is_expected.to validate_presence_of(:full_name).with_message("Enter a full name").on(%i[full_name email]) }
    it { is_expected.to validate_presence_of(:school).with_message("can't be blank").on(%i[email]) }

    context "when the person is already a SIT at the school" do
      let(:induction_tutor) { NewSeeds::Scenarios::Schools::School.new.build.with_an_induction_tutor.induction_tutor }
      let(:form) { described_class.new(full_name:, email: induction_tutor.email, school: induction_tutor.schools.first) }

      it "an error is added" do
        expect(form.valid?(:email)).to be_falsey
        expect(form.errors[:email].first).to eq("The user with email #{form.email} is already an induction coordinator at #{form.school.name}")
      end
    end

    describe "#name_matches" do
      let(:form) { described_class.new(full_name: new_full_name, email:, school:) }

      before do
        create(:ect, user: create(:user, email:, full_name:))
      end

      context "when the name provided doesn't match the intended new SIT's name" do
        let(:new_full_name) { "Another name" }

        it "an error is added" do
          expect(form.valid?(:email)).to be_falsey
          expect(form.errors[:full_name].first).to eq("A user with a different name (#{full_name}) has already been registered with this email address. Change the name or email address you entered.")
        end
      end

      context "when the name is the same but in different case" do
        let(:new_full_name) { full_name.upcase }

        it "an error is added" do
          expect(form.valid?(:email)).to be_truthy
        end
      end
    end

    context "when the email provided is in use by a mentor" do
      let(:form) { described_class.new(full_name:, email:, school:) }

      before do
        create(:mentor, user: create(:user, email:, full_name:))
      end

      it "is valid" do
        expect(form).to be_valid(:email)
      end
    end

    context "when the email provided is in use by an induction tutor" do
      let(:form) { described_class.new(full_name:, email:, school:) }

      before do
        create(:user, :induction_coordinator, full_name:, email:)
      end

      it "is valid" do
        expect(form).to be_valid(:email)
      end
    end

    context "when the email provided is in use by a non-registered person" do
      let(:form) { described_class.new(full_name:, email:, school:) }

      it "is valid" do
        expect(form).to be_valid(:email)
      end
    end
  end

  describe "#save!" do
    let(:start_url) { Rails.application.routes.url_helpers.root_url(host: Rails.application.config.domain, **UTMService.email(:new_induction_tutor)) }
    let(:step_by_step_url) { Rails.application.routes.url_helpers.step_by_step_url(host: Rails.application.config.domain, **UTMService.email(:new_induction_tutor)) }

    subject { described_class.new(full_name:, email:, school:) }

    context "when the previous SIT manages more than a school" do
      let(:previous_sit) { NewSeeds::Scenarios::Schools::School.new.build.with_an_induction_tutor.induction_tutor }

      before do
        previous_sit.induction_coordinator_profile.schools << school
      end

      it "removes the school from their list" do
        expect { subject.save! }.to change { previous_sit.schools.size }.by(-1)
      end
    end

    context "when the previous SIT manages only one school" do
      let(:previous_sit) { NewSeeds::Scenarios::Schools::School.new.build.with_an_induction_tutor.induction_tutor }
      let(:school) { previous_sit.schools.first }
      let(:sit_profile) { previous_sit.induction_coordinator_profile }
    end

    context "when the new SIT is not registered yet" do
      it "they get registered" do
        expect { subject.save! }.to change { User.exists?(email:, full_name:) }.from(false).to(true)
      end
    end

    context "when the new SIT has not SIT profile" do
      let(:new_sit) { create(:user, full_name:, email:) }

      it "one is created for them" do
        expect { subject.save! }.to change { new_sit.reload.induction_coordinator_profile.present? }.from(false).to(true)
      end
    end

    context "when the new SIT manages no school" do
      let(:new_sit) { create(:user, full_name:, email:) }

      it "a first school is added to their list" do
        expect { subject.save! }.to change { new_sit.reload.schools.size }.by(1)
      end
    end

    context "when the new SIT manages other schools" do
      let(:new_sit) { NewSeeds::Scenarios::Schools::School.new.build.with_an_induction_tutor(full_name:, email:).induction_tutor }

      it "the school is added to their list" do
        expect { subject.save! }.to change { new_sit.reload.schools.size }.by(1)
      end
    end

    it "sends an email to the new SIT" do
      expect { subject.save! }.to have_enqueued_mail(SchoolMailer, :nomination_confirmation_email)
    end
  end
end
