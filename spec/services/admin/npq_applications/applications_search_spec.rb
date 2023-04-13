# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::NPQApplications::ApplicationsSearch, :with_default_schedules do
  let(:search) { Admin::NPQApplications::ApplicationsSearch }

  let(:school_1) { create(:school, name: "Greendale School", urn: "123456") }
  let(:school_2) { create(:school, name: "Westview School", urn: "654321") }
  let!(:application_1) { create(:npq_application, user: user_1, school_urn: school_1.urn) }
  let!(:application_2) { create(:npq_application, user: user_2, school_urn: school_2.urn) }
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

    context "when application#private_childcare_provider_urn match" do
      let(:query_string) { 548_675 }

      before do
        application_1.update(private_childcare_provider_urn: query_string)
      end

      it "returns the hit" do
        expect(subject.call).to include(application_1)
      end

      it "does not return the other applications" do
        expect(subject.call).not_to include(application_2)
      end
    end

    context "when partial school name match" do
      let(:query_string) { school_1.name[0, 3] }

      it "returns the hit" do
        expect(subject.call).to include(application_1)
      end

      it "does not return the other applications" do
        expect(subject.call).not_to include(application_2)
      end
    end

    context "when school urn match" do
      let(:query_string) { school_1.urn }

      it "returns the hit" do
        expect(subject.call).to include(application_1)
      end

      it "does not return the other applications" do
        expect(subject.call).not_to include(application_2)
      end
    end
  end
end
