# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class DeliveryPartnerPortal < ::Pages::BasePage
    set_url "/delivery-partners/{delivery_partner_id}/participants"
    set_primary_heading(/^.* Participants$/)

    table :participants, "table.govuk-table" do
      column :full_name
      column :email_address
      column :teacher_reference_number
      column :participant_type
      column :lead_provider_name
      column :school_name
      column :school_urn
      column :academic_year, format: ->(s) { s.to_i }
      column :training_status
      column :training_record_status, format: ->(s) { s.split("\n")[0] }
    end

    def has_delivery_partner_name?(name)
      has_primary_heading? "#{name} Participants"
    end

    def get_participant(full_name)
      @current_full_name = full_name
      select_row
    end

    def has_full_name?(expected_value)
      has_attribute_value? "full_name", expected_value
    end

    def has_email_address?(expected_value)
      has_attribute_value? "email_address", expected_value
    end

    def has_teacher_reference_number?(expected_value)
      has_attribute_value? "teacher_reference_number", expected_value
    end

    def has_participant_type?(expected_value)
      has_attribute_value? "participant_type", expected_value
    end

    def has_lead_provider_name?(expected_value)
      has_attribute_value? "lead_provider_name", expected_value
    end

    def has_school_name?(expected_value)
      has_attribute_value? "school_name", expected_value
    end

    def has_school_urn?(expected_value)
      has_attribute_value? "school_urn", expected_value
    end

    def has_academic_year?(expected_value)
      has_attribute_value? "academic_year", expected_value.to_i
    end

    def has_training_status?(expected_value)
      has_attribute_value? "training_status", expected_value
    end

    def has_training_record_status?(expected_value)
      has_attribute_value? "training_record_status", expected_value
    end

  private

    def select_row
      @current_record = participants.rows.filter { |row| row[:full_name] == @current_full_name }.first

      if @current_record.nil?
        row_names = JSON.pretty_generate(participants.rows.map { |row| row[:full_name] })
        raise Capybara::ElementNotFound, "Unable to find record for \"#{@current_full_name}\" within \n===\n#{row_names}\n===\n"
      end
    end

    def has_attribute_value?(attribute_name, expected_value)
      if @current_record.nil?
        raise "No table row selected, Must call <Pages::DeliveryPartnerPortal::get_participant> with a valid \"full_name\" first"
      end

      value = @current_record[attribute_name.to_sym]
      unless value == expected_value
        raise Capybara::ElementNotFound, "Unable to find attribute \"#{attribute_name}\" for \"#{@current_full_name}\" with value of \"#{expected_value}\" within \n===\n#{JSON.pretty_generate @current_record}\n===\n"
      end

      true
    end
  end
end
