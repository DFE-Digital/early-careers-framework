# frozen_string_literal: true

require "rails_helper"

RSpec.describe NPQ::Accept do
  before { create(:npq_leadership_schedule) }

  let(:cohort_2022) { create(:cohort, :next) }

  subject do
    described_class.new(npq_application: npq_application)
  end

  describe "#call" do
    let(:trn) { rand(1_000_000..9_999_999).to_s }
    let(:user) { create(:user) }
    let(:identity) { create(:participant_identity, user: user) }
    let(:npq_course) { create(:npq_course, identifier: "npq-senior-leadership") }
    let(:npq_lead_provider) { create(:npq_lead_provider) }

    let(:npq_application) do
      NPQApplication.new(
        teacher_reference_number: trn,
        participant_identity: identity,
        npq_course: npq_course,
        npq_lead_provider: npq_lead_provider,
        school_urn: "123456",
        school_ukprn: "12345678",
      )
    end

    context "when user has applied for the same course with another provider" do
      let(:other_npq_lead_provider) { create(:npq_lead_provider) }

      let(:other_npq_application) do
        NPQApplication.new(
          teacher_reference_number: trn,
          participant_identity: identity,
          npq_course: npq_course,
          npq_lead_provider: other_npq_lead_provider,
          school_urn: "123456",
          school_ukprn: "12345678",
        )
      end

      before do
        npq_application.save!
        other_npq_application.save!
      end

      it "rejects other_npq_application" do
        described_class.call(npq_application: npq_application)
        expect(npq_application.reload.lead_provider_approval_status).to eql("accepted")
        expect(other_npq_application.reload.lead_provider_approval_status).to eql("rejected")
      end
    end

    context "when accepting an application for a course that has already been accepted by another provider" do
      let(:other_npq_lead_provider) { create(:npq_lead_provider) }

      let(:other_npq_application) do
        NPQApplication.create!(
          teacher_reference_number: trn,
          participant_identity: identity,
          npq_course: npq_course,
          npq_lead_provider: other_npq_lead_provider,
          school_urn: "123456",
          school_ukprn: "12345678",
        )
      end

      before do
        npq_application.update!(lead_provider_approval_status: "accepted")
      end

      it "does not allow 2 applications with same course to be accepted" do
        expect {
          described_class.call(npq_application: other_npq_application)
        }.not_to change { other_npq_application.reload.lead_provider_approval_status }
      end

      it "attaches errors to the object" do
        described_class.call(npq_application: other_npq_application)
        expect(other_npq_application.errors).to be_present
      end
    end

    context "when user has applied for different course" do
      let(:other_npq_lead_provider) { create(:npq_lead_provider) }
      let(:other_npq_course) { create(:npq_course) }

      let(:other_npq_application) do
        NPQApplication.new(
          teacher_reference_number: trn,
          participant_identity: identity,
          npq_course: other_npq_course,
          npq_lead_provider: other_npq_lead_provider,
          school_urn: "123456",
          school_ukprn: "12345678",
        )
      end

      before do
        npq_application.save!
        other_npq_application.save!
      end

      it "does not reject the other course" do
        described_class.call(npq_application: npq_application)
        expect(npq_application.reload.lead_provider_approval_status).to eql("accepted")
        expect(other_npq_application.reload.lead_provider_approval_status).to eql("pending")
      end
    end

    context "after creating a NPQApplication record" do
      before do
        npq_application.save!
      end

      it "creates teacher and participant profile" do
        expect { subject.call }
          .to change(TeacherProfile, :count).by(1)
          .and change(ParticipantProfile::NPQ, :count).by(1)
      end

      it "creates participant profile correctly" do
        subject.call

        profile = user.teacher_profile.npq_profiles.first

        expect(profile.schedule).to eql(Finance::Schedule::NPQLeadership.default)
        expect(profile.npq_course).to eql(npq_application.npq_course)
        expect(profile.teacher_profile).to eql(user.teacher_profile)
        expect(profile.user).to eql(user)
        expect(profile.school_urn).to eql(npq_application.school_urn)
        expect(profile.school_ukprn).to eql(npq_application.school_ukprn)
      end

      context "when trn is validated" do
        let(:npq_application) do
          NPQApplication.new(
            teacher_reference_number: trn,
            teacher_reference_number_verified: true,
            participant_identity: identity,
            npq_course: npq_course,
            npq_lead_provider: npq_lead_provider,
          )
        end

        it "stores the TRN on teacher profile" do
          subject.call
          npq_application.reload
          expect(npq_application.user.teacher_profile.trn).to eql trn
        end

        context "when another user with same TRN exists" do
          let!(:previous_user) { create(:teacher_profile, trn: trn).user }

          it "transfers participation record onto the previous user" do
            expect { subject.call }
              .to change { previous_user.participant_identities.count }.by(1)
              .and change { previous_user.teacher_profile.participant_profiles.count }.by(1)
          end
        end
      end

      context "when trn is not validated" do
        it "does not store the TRN on teacher profile" do
          subject.call
          npq_application.reload
          expect(npq_application.user.teacher_profile.trn).to be_blank
        end
      end
    end

    context "after approving an existing NPQApplication record" do
      let(:new_trn) { (trn.to_i + 1).to_s }

      before do
        npq_application.save!
        subject.call
        npq_application.update!(teacher_reference_number: new_trn)
      end

      it "does not create neither teacher nor participant profile" do
        expect { subject.call }
          .to change(TeacherProfile, :count).by(0)
          .and change(ParticipantProfile::NPQ, :count).by(0)
      end

      it "returns false" do
        expect(subject.call).to eql(false)
      end

      it "adds errors to object" do
        subject.call
        expect(npq_application.errors).to be_present
      end
    end

    context "when application has already been rejected" do
      before do
        npq_application.lead_provider_approval_status = "rejected"
        npq_application.save!
      end

      it "cannot then be accepted" do
        expect {
          subject.call
        }.not_to change { npq_application.reload.lead_provider_approval_status }
      end
    end

    context "when applying for 2022" do
      let!(:npq_application) do
        NPQApplication.create!(
          teacher_reference_number: trn,
          participant_identity: identity,
          npq_course: npq_course,
          npq_lead_provider: npq_lead_provider,
          school_urn: "123456",
          school_ukprn: "12345678",
          cohort: cohort_2022,
        )
      end

      context "there is a 2021 pending application" do
        let!(:previous_npq_application) do
          NPQApplication.create!(
            teacher_reference_number: trn,
            participant_identity: identity,
            npq_course: npq_course,
            npq_lead_provider: npq_lead_provider,
            school_urn: "123456",
            school_ukprn: "12345678",
            cohort: Cohort.find_by!(start_year: 2021),
          )
        end

        it "does not affect 2021 application" do
          expect {
            subject.call
          }.to change { npq_application.reload.lead_provider_approval_status }
           .and not_change { previous_npq_application.reload.lead_provider_approval_status }
        end
      end
    end
  end
end
