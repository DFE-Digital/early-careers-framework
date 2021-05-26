# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolEmailUpdateJob do
  describe "#perform" do
    it "should run the school data importer" do
      expect_any_instance_of(SchoolDataImporter).to receive(:update_emails)

      SchoolEmailUpdateJob.new.perform
    end
  end
end
