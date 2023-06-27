# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::NPQApplications::EdgeCaseSearch do
  let(:search) { Admin::NPQApplications::EdgeCaseSearch }

  let!(:application_1) { create(:npq_application, user: user_1) }
  let!(:application_2) { create(:npq_application, user: user_2) }
  let!(:application_3) { create(:npq_application, user: user_1, employer_name: "Salford", funding_eligiblity_status_code: "no_institution", employment_type: "hospital_school", works_in_school: false, works_in_childcare: false) }
  let!(:application_4) { create(:npq_application, user: user_2, employer_name: "Learning", funding_eligiblity_status_code: "previously_funded", employment_type: "other") }
  let!(:participant_identity_1) { create(:participant_identity, email: "aajohn-doe123@example.com") }
  let!(:participant_identity_2) { create(:participant_identity, email: "bbalaric123@example.com") }
  let!(:teacher_profile_1) { create(:teacher_profile, user: user_1) }
  let!(:teacher_profile_2) { create(:teacher_profile, user: user_2) }
  let!(:schedule_1) { create(:schedule, name: "Schedule1") }
  let!(:schedule_2) { create(:schedule, name: "Schedule2") }
  let(:user_1) { create(:user, full_name: "John Doe", email: "john-doe@example.com") }
  let(:user_2) { create(:user, full_name: "Alaric Smithee", email: "alaric@example.com") }

  subject { described_class.new(query_string:) }

  describe "#call" do
    context "when partial email match" do
      let(:query_string) { user_1.email.split("@").first }

      it "returns the hit" do
        expect(subject.call).to include(application_1)
      end

      it "does not return the other applications" do
        expect(subject.call).not_to include(application_2)
      end
    end

    context "when user#id match" do
      let(:query_string) { user_1.id }

      it "returns the hit" do
        expect(subject.call).to include(application_1)
      end

      it "does not return the other applications" do
        expect(subject.call).not_to include(application_2)
      end
    end

    context "when partial name match" do
      let(:query_string) { user_1.full_name[0, 3] }

      it "returns the hit" do
        expect(subject.call).to include(application_1)
      end

      it "does not return the other applications" do
        expect(subject.call).not_to include(application_2)
      end
    end

    context "when application#id match" do
      let(:query_string) { application_1.id }

      it "returns the hit" do
        expect(subject.call).to include(application_1)
      end

      it "does not return the other applications" do
        expect(subject.call).not_to include(application_2)
      end
    end

    context "when application#teacher_reference_number match" do
      let(:query_string) { application_1.teacher_reference_number }

      it "returns the hit" do
        expect(subject.call).to include(application_1)
      end

      it "does not return the other applications" do
        expect(subject.call).not_to include(application_2)
      end
    end

    context "when partial application#employer_name match" do
      let(:query_string) { application_3.employer_name }

      it "returns the hit" do
        expect(subject.call).to include(application_3)
      end

      it "does not return the other applications" do
        expect(subject.call).not_to include(application_4)
      end
    end

    context "when teacherProfile#trn match" do
      let(:query_string) { teacher_profile_1.trn }

      it "returns the hit" do
        expect(subject.call).to include(application_1)
      end

      it "does not return the other applications" do
        expect(subject.call).not_to include(application_2)
      end
    end

    context "when fundingEligibilityStatusCode match" do
      subject { described_class.new(funding_eligiblity_status_code:) }
      let(:funding_eligiblity_status_code) { application_3.funding_eligiblity_status_code }

      it "returns the hit" do
        expect(subject.call).to include(application_3)
      end

      it "does not return the other applications" do
        expect(subject.call).not_to include(application_4)
      end
    end

    context "when employmentType match" do
      subject { described_class.new(employment_type:) }
      let(:employment_type) { application_3.employment_type }

      it "returns the hit" do
        expect(subject.call).to include(application_3)
      end

      it "does not return the other applications" do
        expect(subject.call).not_to include(application_4)
      end
    end

    context "when createdAt match" do
      subject { described_class.new(start_date:, end_date:) }
      let(:start_date) { application_3.created_at - 1.day }
      let(:end_date) { application_4.created_at + 1.day }

      it "returns the hit" do
        expect(subject.call).to include(application_3)
      end

      it "does not return the other applications" do
        expect(subject.call).not_to include(application_4)
      end
    end
  end
end
