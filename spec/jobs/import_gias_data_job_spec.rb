# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ImportGiasDataJob" do
  describe "#perform" do
    it "should run the GIAS data importer" do
      files = {
        school_data_file: "file.csv",
        school_links_file: "links.csv",
      }

      fetch_gias_files = class_double("DataStage::FetchGiasDataFiles")
        .as_stubbed_const(transfer_nested_contants: true)

      update_staged_schools = class_double("DataStage::UpdateStagedSchools")
        .as_stubbed_const(transfer_nested_contants: true)

      expect(fetch_gias_files).to receive(:call).and_yield(files)
      expect(update_staged_schools).to receive(:call).with(files)

      ImportGiasDataJob.new.perform
    end
  end
end
