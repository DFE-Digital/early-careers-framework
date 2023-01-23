# frozen_string_literal: true

require "rails_helper"

RSpec.describe Schools::SearchQuery do
  describe "#call" do
    let!(:school_a) { create(:school, name: "School A", urn: "090120", postcode: "M1 2WD") }
    let!(:school_b) { create(:school, name: "School B", urn: "090550", postcode: "M1 3BD") }
    let!(:school_c) { create(:school, name: "School C", urn: "333333") }

    subject { described_class.new(query:).call }

    context "when the query includes part of the name of a school/s" do
      let(:query) { "A" }

      it "searches schools by name" do
        expect(subject).to match_array([school_a])
      end
    end

    context "when the query includes part of the urn of a school/s" do
      let(:query) { "090" }

      it "searches schools by urn" do
        expect(subject).to match_array([school_a, school_b])
      end
    end

    context "when the query includes part of the email of a SIT/s" do
      let(:query) { "schools.org" }

      before do
        create(:user, :induction_coordinator, email: "sit_a@schools.org", schools: [school_a])
        create(:user, :induction_coordinator, email: "sit_c@schools.org", schools: [school_c])
      end

      it "searches schools by sit's email" do
        expect(subject).to match_array([school_a, school_c])
      end

      context "when there is more than one induction coordinator for the same school" do
        let(:query) { "sit_a" }

        before do
          create(:user, :induction_coordinator, email: "old_sit_a@schools.org", schools: [school_a])
        end

        it "only returns the school once" do
          expect(subject).to match_array([school_a])
        end
      end
    end

    context "when the query includes part of the postcode of a school/s" do
      let(:query) { "M1" }

      it "searches schools by sit's email" do
        expect(subject).to match_array([school_a, school_b])
      end
    end
  end
end
