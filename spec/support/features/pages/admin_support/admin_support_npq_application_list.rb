# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class AdminSupportNPQApplicationList < ::Pages::BasePage
    set_url "/admin/npq/applications/applications"
    set_primary_heading("NPQ Applications")

    table :npq_application_data, "table.govuk-table" do
      column :email_address
      column :npq_course
      column :npq_lead_provider
      column :school_urn
      column :funding, format: ->(s) { s == "true" }
      column :link
    end

    def view_application(application_email)
      table_cell = page.find(:css, "td", text: application_email)
      table_row = table_cell.find(:xpath, "./parent::tr")
      within(table_row) do
        click_on "View"
      end

      Pages::AdminSupportNPQApplicationDetail.loaded
    end

    def get_application(application_email)
      @current_application_email = application_email
      select_row
    end

    def has_email_address?(expected_value)
      has_attribute_value? "email_address", expected_value
    end

    def has_npq_course?(expected_value)
      has_attribute_value? "npq_course", expected_value
    end

    def has_npq_lead_provider?(expected_value)
      has_attribute_value? "npq_lead_provider", expected_value
    end

    def has_school_urn?(expected_value)
      has_attribute_value? "school_urn", expected_value
    end

    def funded?
      has_attribute_value? "funding", true
    end

    def not_funded?
      has_attribute_value? "funding", false
    end

    def has_link?(expected_value)
      has_attribute_value? "link", expected_value
    end

  private

    def select_row
      @current_record = npq_application_data.rows.filter { |row| row[:email_address] == @current_application_email }.first

      if @current_record.nil?
        row_names = JSON.pretty_generate(npq_application_data.rows.map { |row| row[:email_address] })
        raise Capybara::ElementNotFound, "Unable to find record for \"#{@current_application_email}\" within \n===\n#{row_names}\n===\n"
      end
    end

    def has_attribute_value?(attribute_name, expected_value)
      if @current_record.nil?
        raise "No table row selected, Must call <Pages::AdminSupportNPQApplicationList::get_application> with a valid \"npq_application_email\" first"
      end

      value = @current_record[attribute_name.to_sym]
      unless value == expected_value
        raise Capybara::ElementNotFound, "Unable to find attribute \"#{attribute_name}\" for \"#{@current_application_email}\" with value of \"#{expected_value}\" within \n===\n#{JSON.pretty_generate @current_record}\n===\n"
      end

      true
    end
  end
end
