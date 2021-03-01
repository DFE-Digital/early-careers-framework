# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolSearchForm, type: :model do
  describe "find_schools" do
    let!(:schools) do
      [create(:school, name: "Test school one", urn: "1234567"),
       create(:school, name: "Amazing school", urn: "2345678"),
       create(:school, name: "Academy", urn: "3456789")]
    end
    let(:lead_provider) { create(:lead_provider) }
    let(:cohort) { create(:cohort, start_year: 2021) }

    describe "school_name" do
      it "finds schools that include lowercase part of name" do
        form = SchoolSearchForm.new(school_name: "test")
        schools = form.find_schools(1)
        expect(schools.count).to eq(1)
        expect(schools.first.name).to eq("Test school one")
      end

      it "finds all schools with empty query" do
        form = SchoolSearchForm.new(school_name: "")
        schools = form.find_schools(1)
        expect(schools.count).to eq(3)
      end

      it "finds school with matching Unique Reference Number (URN)" do
        form = SchoolSearchForm.new(school_name: "2345678")
        schools = form.find_schools(1)
        expect(schools.count).to eq(1)
        expect(schools.first.name).to eql("Amazing school")
      end

      it "finds all schools with an empty query" do
        form = SchoolSearchForm.new(school_name: "")
        schools = form.find_schools(1)
        expect(schools.count).to eq(3)
      end
    end

    describe "characteristics" do
      it "shows only pupil premium schools" do
        # Given
        school = create(:school, :pupil_premium_uplift)

        # When
        form = SchoolSearchForm.new(characteristics: %w[pupil_premium_above_40])
        schools = form.find_schools(1)

        # Then
        expect(schools.count).to be 1
        expect(schools).to include(school)
      end

      it "shows only sparse schools" do
        # Given
        school = create(:school, :sparsity_uplift)

        # When
        form = SchoolSearchForm.new(characteristics: %w[top_20_remote_areas])
        schools = form.find_schools(1)

        # Then
        expect(schools.count).to be 1
        expect(schools).to include(school)
      end

      it "shows sparse OR pupil premium schools" do
        # Given
        pupil_premium_school = create(:school, :pupil_premium_uplift)
        sparse_school = create(:school, :sparsity_uplift)

        # When
        form = SchoolSearchForm.new(characteristics: %w[pupil_premium_above_40 top_20_remote_areas])
        schools = form.find_schools(1)

        # Then
        expect(schools.count).to be 2
        expect(schools).to include(pupil_premium_school)
        expect(schools).to include(sparse_school)
      end

      it "shows pupil premium AND sparse schools" do
        # Given
        school = create(:school, :pupil_premium_uplift, :sparsity_uplift)

        # When
        form = SchoolSearchForm.new(characteristics: %w[pupil_premium_above_40 top_20_remote_areas])
        schools = form.find_schools(1)

        # Then
        expect(schools.count).to be 1
        expect(schools).to include(school)
      end

      it "shows all schools when given blank characteristics" do
        # When
        form = SchoolSearchForm.new(characteristics: ["", ""])
        schools = form.find_schools(1)

        # Then
        expect(schools.count).to be 3
      end
    end

    describe "partnership" do
      let!(:school) do
        school = schools[2]
        Partnership.create!(school: school, lead_provider: lead_provider, cohort: cohort)
        school
      end

      it "removes schools in a partnership" do
        # When
        form = SchoolSearchForm.new(partnership: [""])
        schools = form.find_schools(1)

        # Then
        expect(schools.count).to be 2
        expect(schools).to_not include(school)
      end

      it "shows schools in a partnership when the option is selected" do
        # When
        form = SchoolSearchForm.new(partnership: %w[in_a_partnership])
        schools = form.find_schools(1)

        # Then
        expect(schools.count).to be 3
        expect(schools).to include(school)
      end
    end

    describe "local_authorities" do
      let!(:local_authority) { create(:local_authority) }
      let!(:school) do
        school = create(:school)
        create(:school_local_authority, school: school, local_authority: local_authority)
        school
      end

      it "only includes schools matching the local authority" do
        # When
        form = SchoolSearchForm.new(local_authorities: [local_authority.id])
        schools = form.find_schools(1)

        # Then
        expect(schools.count).to be 1
        expect(schools).to include(school)
      end
    end

    describe "networks" do
      let!(:network) { create(:network) }
      let!(:school) { create(:school, network: network) }

      it "only includes schools from the matching network" do
        # When
        form = SchoolSearchForm.new(networks: [network.id])
        schools = form.find_schools(1)

        # Then
        expect(schools.count).to be 1
        expect(schools).to include(school)
      end
    end
  end
end
