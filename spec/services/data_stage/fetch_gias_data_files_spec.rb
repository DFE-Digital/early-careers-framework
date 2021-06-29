# frozen_string_literal: true

require "rails_helper"

RSpec.describe DataStage::FetchGiasDataFiles do
  let(:ecf_tech_csv) { File.open("spec/fixtures/files/gias_response/ecf_tech.csv") }
  let(:group_links_csv) { File.open("spec/fixtures/files/gias_response/groupLinks.csv") }
  let(:groups_csv) { File.open("spec/fixtures/files/gias_response/groups.csv") }
  let(:links_csv) { File.open("spec/fixtures/files/gias_response/links.csv") }
  let(:files) do
    {
      "ecf_tech.csv" => ecf_tech_csv,
      "groupLinks.csv" => group_links_csv,
      "groups.csv" => groups_csv,
      "links.csv" => links_csv,
    }
  end

  before do
    allow_any_instance_of(GiasApiClient).to receive(:get_files).and_return(files)
  end

  describe ".call" do
    it "dowloads the gias data files and yields to a given block" do
      block_params = {
        school_data_file: files["ecf_tech.csv"].path,
        school_links_file: files["links.csv"].path,
      }
      expect { |b| described_class.call(&b) }.to yield_with_args(block_params)
    end
  end
end
