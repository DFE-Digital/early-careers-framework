# frozen_string_literal: true

require "rails_helper"

RSpec.describe PartnershipCsvUpload, type: :model do
  let!(:current_cohort) { Cohort.current || create(:cohort, :current) }
  let(:valid_school) { create(:school) }
  let(:welsh_school) { create(:school, administrative_district_code: "W123", school_type_code: 30) }
  let(:closed_school) { create(:school, school_status_code: 2) }

  describe "associations" do
    it { is_expected.to belong_to(:lead_provider).optional }
    it { is_expected.to belong_to(:delivery_partner).optional }
  end

  describe "relations" do
    it { is_expected.to have_one(:csv_attachment) }
  end

  describe "csv_validation" do
    let(:csv_upload) { build(:partnership_csv_upload, :with_csv) }
    let(:text_upload) { build(:partnership_csv_upload, :with_text) }

    context "when CSV file is too large" do
      before do
        allow(csv_upload.csv)
          .to receive(:byte_size).and_return 3.megabytes
      end

      it "is invalid" do
        expect(csv_upload).to be_invalid
      end
    end

    context "when file extension is not csv" do
      it "is invalid" do
        expect(text_upload).to be_invalid
      end
    end
  end

  describe "#invalid schools" do
    it "finds invalid URNs" do
      given_the_csv_contains_urns([valid_school.urn, 1])

      expect(@subject.invalid_schools.length).to eql 1
      expect(@subject.invalid_schools).to contain_exactly({ urn: "1", row_number: 2, school_name: "", message: "URN is not valid" })
    end

    it "finds CIP only schools" do
      given_the_csv_contains_urns([welsh_school.urn])

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
      given_the_csv_contains_urns([closed_school.urn])

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
      given_the_csv_contains_urns([partnered_school.urn])
      Partnership.create!(
        school: partnered_school,
        lead_provider: @subject.lead_provider,
        delivery_partner: @subject.delivery_partner,
        cohort: current_cohort,
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

    context "school already recruited by other provider" do
      it "errors when school is partnered in previous year and hasn't created the following year cohort" do
        school_cohort = create(:school_cohort, cohort: current_cohort)
        next_cohort = Cohort.next || create(:cohort, :next)
        create(:partnership, school: school_cohort.school)

        given_the_csv_contains_urns([school_cohort.school.urn], cohort: next_cohort)

        expect(@subject.invalid_schools.length).to eql 1
        expect(@subject.invalid_schools).to contain_exactly(
          {
            urn: school_cohort.school.urn,
            row_number: 1,
            school_name: school_cohort.school.name,
            message: "Recruited by other provider",
          },
        )
      end

      it "errors when school is with a lead provider" do
        partnership = create(:partnership, cohort: current_cohort)
        partnered_school = partnership.school
        given_the_csv_contains_urns([partnered_school.urn])

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
      given_the_csv_contains_urns(urns)

      expect(@subject.urns).to eql urns
    end

    it "returns unique URNs" do
      urns = [1, 1, 2, 2, 3, 3]
      given_the_csv_contains_urns(urns)

      expect(@subject.urns).to eql %w[1 2 3]
    end

    it "removes BOM from the input" do
      urns = %w[1 2 3]
      given_the_csv_contains_urns(urns, insert_bom: true)

      expect(@subject.urns).to eql %w[1 2 3]
    end
  end

  describe "#valid_schools" do
    it "returns only valid schools" do
      given_the_csv_contains_urns([valid_school.urn, closed_school.urn])

      expect(@subject.valid_schools).to contain_exactly(valid_school)
    end

    it "deals with leading zeros in URNs" do
      school_with_leading_zero = create(:school, urn: "20001")
      given_the_csv_contains_urns(%w[020001])

      expect(@subject.valid_schools).to contain_exactly(school_with_leading_zero)
    end
  end

  describe "#sync_uploaded_urns" do
    it "populates the uploaded_urns field with the CSV contents" do
      urns = [1, 1, 2, 2, 3, 3]
      given_the_csv_contains_urns(urns, insert_bom: true)

      expect(@subject.uploaded_urns).to be_blank

      @subject.sync_uploaded_urns

      expect(@subject.uploaded_urns).to eql(urns.map(&:to_s))
    end
  end

private

  def given_the_csv_contains_urns(urns, cohort: current_cohort, insert_bom: false)
    bom = "\xEF\xBB\xBF"

    file = Tempfile.new
    file.write(bom) if insert_bom
    file.write(urns.join("\n"))
    file.close

    if insert_bom
      expect(File.read(file).bytes).to start_with(bom.bytes)
    end

    @subject = build(:partnership_csv_upload, cohort:)
    @subject.csv.attach(io: File.open(file), filename: "test.csv", content_type: "text/csv")
    @subject.save!
  ensure
    file&.unlink
  end
end
