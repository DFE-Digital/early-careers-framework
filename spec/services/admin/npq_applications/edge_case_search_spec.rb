# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::NPQApplications::EdgeCaseSearch, :with_default_schedules do
  let(:search) { Admin::NPQApplications::EdgeCaseSearch }

  let!(:application_1) { create(:npq_application, user: user_1) }
  let!(:application_2) { create(:npq_application, user: user_2) }
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
  end
end
