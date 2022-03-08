# frozen_string_literal: true

module Pages
  class LeadProviderConfirmYourSchoolsWizard
    include Capybara::DSL

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
      CSV.open("school_urns.csv", "w") do |csv|
        school_urns.each { |urn| csv << [urn] }
      end
      attach_file("CSV file", "school_urns.csv")
      click_on "Continue"
      File.delete("school_urns.csv")
    end
  end
end
