# frozen_string_literal: true

require_relative "../base"

module Pages
  class LeadProviderConfirmYourSchoolsWizard < ::Pages::Base
    set_url "/lead-providers/report-schools/start"
    set_primary_heading "XXX"

    def complete(delivery_partner_name, school_urns)
      click_on "Continue"
      choose_delivery_partner delivery_partner_name
      upload_school_urns school_urns
      click_on "Confirm"
    end

    def choose_delivery_partner(delivery_partner_name)
      choose delivery_partner_name
      click_on "Continue"
    end

    def upload_school_urns(school_urns)
      csv_filepath = "tmp/school_urns.csv"

      CSV.open(csv_filepath, "w") do |csv|
        school_urns.each { |urn| csv << [urn] }
      end
      attach_file("CSV file", csv_filepath)
      click_on "Continue"
      File.delete(csv_filepath)
    end
  end
end
