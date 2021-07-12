# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Pages for induction tutor materials for existing CIPs", type: :request do
  before do
    seed_path = %w[db seeds]

    load Rails.root.join(*seed_path, "initial_seed.rb").to_s
  end

  describe "GET /induction-tutor-materials/:provider/:year" do

    it "renders the materials template for Ambition" do
      provider = CoreInductionProgramme.find_by!(name: "Ambition Institute")
      get induction_tutor_materials_path(provider: provider.name.downcase.tr(" ", "-"), year: "year-one")
      expect(response.status).to eq 200

      get induction_tutor_materials_path(provider: provider.name.downcase.tr(" ", "-"), year: "year-two")
      expect(response.status).to eq 200
    end

    it "renders the materials template for EDT" do
      provider = CoreInductionProgramme.find_by!(name: "Education Development Trust")
      get induction_tutor_materials_path(provider: provider.name.downcase.tr(" ", "-"), year: "year-one")
      expect(response.status).to eq 200

      get induction_tutor_materials_path(provider: provider.name.downcase.tr(" ", "-"), year: "year-two")
      expect(response.status).to eq 200
    end

    it "renders the materials template for Teach First" do
      provider = CoreInductionProgramme.find_by!(name: "Teach First")
      get induction_tutor_materials_path(provider: provider.name.downcase.tr(" ", "-"), year: "year-one")
      expect(response.status).to eq 200
    end

    it "renders the materials template for UCL" do
      provider = CoreInductionProgramme.find_by!(name: "UCL Institute of Education")
      get induction_tutor_materials_path(provider: provider.name.downcase.tr(" ", "-"), year: "year-one")
      expect(response.status).to eq 200

      get induction_tutor_materials_path(provider: provider.name.downcase.tr(" ", "-"), year: "year-two")
      expect(response.status).to eq 200
    end
  end
end
