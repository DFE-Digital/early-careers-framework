# frozen_string_literal: true

require "rails_helper"
require "csv"

RSpec.describe AdditionalEmailImporter do
  let(:example_csv_file) { "spec/fixtures/files/example_emails.csv" }
  let(:additional_email_importer) { AdditionalEmailImporter.new(Logger.new($stdout), example_csv_file) }

  before do
    create(:school, urn: 100_000)
    create(:school, urn: 100_001)
    create(:school, urn: 100_002)
    create(:school, urn: 100_003)
  end

  describe "#run" do
    before do
      additional_email_importer.run
    end

    it "adds multiple emails to a single school" do
      created_emails = School.find_by(urn: 100_000).additional_school_emails
      expect(created_emails.length).to eql 2
      expect(created_emails.map(&:email_address)).to match_array %w[head@example.com admin@example.com]
    end

    it "strips slashes from emails" do
      created_email = School.find_by(urn: 100_001).additional_school_emails.first

      expect(created_email.email_address).to eql "info@example.com"
    end

    it "does not create emails with banned words" do
      expect(AdditionalSchoolEmail.where(email_address: "covid-info@example.com").count).to eql 0
      expect(AdditionalSchoolEmail.where(email_address: "admissions@example.com").count).to eql 0
    end
  end
end
