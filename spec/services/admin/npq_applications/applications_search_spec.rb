# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::NPQApplications::ApplicationsSearch, :with_default_schedules do
  let(:search) { Admin::NPQApplications::ApplicationsSearch }

  let!(:school) { create(:school) }
  let!(:application_1) { create(:npq_application, school_urn: school.urn) }
  let!(:application_2) { create(:npq_application, school_urn: school.urn) }
  let!(:user) { application_1.user }

  subject { described_class.new(query_string:) }

  describe "#call" do
    context "when partial email match" do
      let(:query_string) { user.email.split("@").first }

      it "returns the hit" do
        expect(subject.call).to include(application_1)
      end
    end

    context "when user#id match" do
      let(:query_string) { user.id }

      it "returns the hit" do
        expect(subject.call).to include(application_1)
      end
    end

    context "when partial name match" do
      let(:query_string) { user.full_name[0, 3] }

      it "returns the hit" do
        expect(subject.call).to include(application_1)
      end
    end

    context "when application#id match" do
      let(:query_string) { application_1.id }

      it "returns the hit" do
        expect(subject.call).to include(application_1)
      end
    end

    context "when application#teacher_reference_number match" do
      let(:query_string) { application_1.teacher_reference_number }

      it "returns the hit" do
        expect(subject.call).to include(application_1)
      end
    end

    context "when application#private_childcare_provider_urn match" do
      let(:query_string) { application_1.private_childcare_provider_urn }

      it "returns the hit" do
        expect(subject.call).to include(application_1)
      end
    end

    context "when partial school name match" do
      let(:query_string) { school.name[0, 3] }

      it "returns the hit" do
        expect(subject.call).to include(application_1)
      end
    end

    context "when school urn match" do
      let(:query_string) { school.urn }

      it "returns the hit" do
        expect(subject.call).to include(application_1)
      end
    end
  end
end
