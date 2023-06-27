# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Pages for induction tutor materials for existing CIPs", type: :request do
  let(:cip_materials_ambition) { FactoryBot.create :core_induction_programme, name: "Ambition Institute" }
  let(:cip_materials_edt) { FactoryBot.create :core_induction_programme, name: "Education Development Trust" }
  let(:cip_materials_tf) { FactoryBot.create :core_induction_programme, name: "Teach First" }
  let(:cip_materials_ucl) { FactoryBot.create :core_induction_programme, name: "UCL Institute of Education" }

  describe "GET /induction-tutor-materials/:provider/year-one" do
    let(:year) { "year-one" }

    %w[
      ambition-institute
      education-development-trust
      teach-first
      ucl-institute-of-education
    ].each do |materials_provider_id|
      it "renders the year one materials template for #{materials_provider_id}" do
        get induction_tutor_materials_path(provider: materials_provider_id, year:)
        expect(response.status).to eq 200
      end
    end

    it "fails to renders the year one materials template for anything else" do
      expect { get induction_tutor_materials_path(provider: "harvard-institute", year:) }.to raise_error ActionView::MissingTemplate
    end
  end

  describe "GET /induction-tutor-materials/:provider/year-two" do
    let(:year) { "year-two" }

    %w[
      ambition-institute
      education-development-trust
      ucl-institute-of-education
    ].each do |materials_provider_id|
      it "renders the year two materials template for #{materials_provider_id}" do
        get induction_tutor_materials_path(provider: materials_provider_id, year:)
        expect(response.status).to eq 200
      end
    end

    it "fails to renders the year one materials template for anything else" do
      expect { get induction_tutor_materials_path(provider: "harvard-institute", year:) }.to raise_error ActionView::MissingTemplate
    end
  end
end
