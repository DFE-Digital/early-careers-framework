# frozen_string_literal: true

require "rails_helper"

RSpec.describe PartnershipCsvUpload, type: :model do
  let!(:cohort) { Cohort.current || create(:cohort, :current) }
  let(:valid_school) { create(:school) }
  let(:welsh_school) { create(:school, administrative_district_code: "W123", school_type_code: 30) }
  let(:closed_school) { create(:school, school_status_code: 2) }

  describe "associations" do
    it { is_expected.to belong_to(:lead_provider).optional }
    it { is_expected.to belong_to(:delivery_partner).optional }
  end

  describe "#invalid schools" do
    it "finds invalid URNs" do
      @subject = create(:partnership_csv_upload, cohort:, uploaded_urns: [valid_school.urn, 1])

      expect(@subject.invalid_schools.length).to eql 1
      expect(@subject.invalid_schools).to contain_exactly({ urn: "1", row_number: 2, school_name: "", message: "URN is not valid" })
    end

    it "finds CIP only schools" do
      @subject = create(:partnership_csv_upload, cohort:, uploaded_urns: [welsh_school.urn])

      expect(@subject.invalid_schools.length).to eql 1
      expect(@subject.invalid_schools).to contain_exactly(
        {
          urn: welsh_school.urn,
          row_number: 1,
          school_name: welsh_school.name,
          message: "School not eligible for funding",
        },
      )
    end

    it "finds ineligible schools" do
      @subject = create(:partnership_csv_upload, cohort:, uploaded_urns: [closed_school.urn])

      expect(@subject.invalid_schools.length).to eql 1
      expect(@subject.invalid_schools).to contain_exactly(
        {
          urn: closed_school.urn,
          row_number: 1,
          school_name: closed_school.name,
          message: "School not eligible for inductions",
        },
      )
    end

    it "finds schools already in a partnership with the lead provider" do
      partnered_school = create(:school)
      @subject = create(:partnership_csv_upload, cohort:, uploaded_urns: [partnered_school.urn])
      Partnership.create!(
        school: partnered_school,
        lead_provider: @subject.lead_provider,
        delivery_partner: @subject.delivery_partner,
        cohort:,
      )

      expect(@subject.invalid_schools.length).to eql 1
      expect(@subject.invalid_schools).to contain_exactly(
        {
          urn: partnered_school.urn,
          row_number: 1,
          school_name: partnered_school.name,
          message: "Your school - already confirmed",
        },
      )
    end

    context "when a school ran FIP in the last cohort but hasn't made a choice for the following year" do
      let(:school_cohort) { create(:school_cohort, cohort:) }
      let(:next_cohort) { Cohort.next || create(:cohort, :next) }

      before do
        @subject = create(:partnership_csv_upload, cohort: next_cohort, uploaded_urns: [school_cohort.school.urn])
      end

      it "errors when school is partnered in previous year with a different provider" do
        create(:partnership, school: school_cohort.school, lead_provider: create(:lead_provider, name: "A Different Provider Ltd"))

        expect(@subject.invalid_schools.length).to eql 1
        expect(@subject.invalid_schools).to contain_exactly(
          {
            urn: school_cohort.school.urn,
            row_number: 1,
            school_name: school_cohort.school.name,
            message: "School programme not yet confirmed",
          },
        )
      end

      it "errors when school is partnered in previous year with the same provider" do
        create(:partnership, school: school_cohort.school, lead_provider: @subject.lead_provider)

        expect(@subject.invalid_schools.length).to eql 1
        expect(@subject.invalid_schools).to contain_exactly(
          {
            urn: school_cohort.school.urn,
            row_number: 1,
            school_name: school_cohort.school.name,
            message: "School programme not yet confirmed",
          },
        )
      end
    end

    context "school already recruited by other provider" do
      it "errors when school is with a lead provider" do
        partnership = create(:partnership, cohort:)
        partnered_school = partnership.school
        @subject = create(:partnership_csv_upload, cohort:, uploaded_urns: [partnered_school.urn])

        expect(@subject.invalid_schools.length).to eql 1
        expect(@subject.invalid_schools).to contain_exactly(
          {
            urn: partnered_school.urn,
            row_number: 1,
            school_name: partnered_school.name,
            message: "Recruited by other provider",
          },
        )
      end
    end
  end

  describe "#urns" do
    it "returns the correct URNs" do
      urns = 5.times.map { Faker::Number.unique.decimal_part(digits: 7).to_s }
      @subject = create(:partnership_csv_upload, cohort:, uploaded_urns: urns)

      expect(@subject.urns).to eql urns
    end

    it "returns unique URNs" do
      urns = [1, 1, 2, 2, 3, 3]
      @subject = create(:partnership_csv_upload, cohort:, uploaded_urns: urns)

      expect(@subject.urns).to eql %w[1 2 3]
    end

    it "removes BOM from the input" do
      urns = %w[1 2 3]
      @subject = create(:partnership_csv_upload, cohort:, uploaded_urns: urns)

      expect(@subject.urns).to eql %w[1 2 3]
    end
  end

  describe "#valid_schools" do
    it "returns only valid schools" do
      @subject = create(:partnership_csv_upload, cohort:, uploaded_urns: [valid_school.urn, closed_school.urn])

      expect(@subject.valid_schools).to contain_exactly(valid_school)
    end

    it "deals with leading zeros in URNs" do
      school_with_leading_zero = create(:school, urn: "20001")
      @subject = create(:partnership_csv_upload, cohort:, uploaded_urns: %w[020001])

      expect(@subject.valid_schools).to contain_exactly(school_with_leading_zero)
    end
  end
end
