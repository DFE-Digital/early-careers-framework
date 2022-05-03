# frozen_string_literal: true

module Pages
  class FinancePaymentBreakdownReport
    include Capybara::DSL

    class Table
      include Capybara::DSL

      def initialize(caption)
        self.element = find("caption", text: caption)
      end

      def row_labelled(label)
        tbody.has_css?("tr", text: label) &&
          tbody.find("tr", text: label).all("td,th")
      end

      def column(column_header)
        rows.map { |row| row.find("td:nth-child(#{column_index(column_header)})") }
      end

      def header(column_header)
        headers.detect { |header| header.text == column_header }
      end

      def cell(row, column_header)
        row_labelled(row)[column_index(column_header)]
      end

      def row
        row_labelled(row)
      end

    private

      attr_accessor :element

      def column_index(column_header)
        headers.index(header(column_header))
      end

      def rows
        tbody.all("tr")
      end

      def headers
        thead.all("tr th")
      end

      def tbody
        element.sibling("tbody")
      end

      def thead
        element.sibling("thead")
      end
    end

    TABLE_COLOMNS_BANDS_MAPPING = {
      a: 1, b: 2, c: 3, d: 4
    }.freeze

    DECLARATION_TYPE_ROWS = [
      "Starts",
      "Retained 1",
      "Retained 1",
      "Retained 1",
      "Retained 1",
      "Completed",
    ].freeze

    def adjustments_table
      @adjustments_table ||= Table.new("Adjustments")
    end

    def output_payments_table
      @output_payments_table ||= Table.new("Output payments")
    end

    def output_payments_table_body
      find("caption", text: "Output payments").sibling("tbody")
    end

    def find_row_labled(table, declaration_type, row_type: "th")
      table.find("tr #{row_type}", text: declaration_type)
    end

    def row_for_declaration_type(table, declaration_type)
      find_row_labled(table, declaration_type).all("~td")
    end

    def bands_for_row(table, declaration_type)
      row_for_declaration_type(table, declaration_type)[0, TABLE_COLOMNS_BANDS_MAPPING[:d]]
    end

    def payment_for_declaration_type(table, declaration_type)
      row_for_declaration_type(table, declaration_type).last
    end

    def output_payments_table_per_band_td
      DECLARATION_TYPE_ROWS.flat_map do |declaration_type|
        bands_for_row(output_payments_table_body, declaration_type).to_a
      end
    end

    def total_declarations
      output_payments_table_per_band_td.map(&:text).map(&:to_i).sum
    end

    def total_starts_summary
      find("strong", text: "Total starts").sibling("div")
    end

    def can_see_started_declaration_payment_amount_table?(num_ects, num_mentors, num_declarations)
      total_in_band = (num_ects + num_mentors) * num_declarations
      total_payment = total_in_band == 0 ? "£0.00" : "£119.40"

      total_starts_summary.text == total_in_band.to_s && payment_for_declaration_type(output_payments_table, "Starts").text == total_payment
    end

    def can_see_retained_1_declaration_payment_table?(num_ects, num_mentors, num_declarations)
      total_in_band = (num_ects + num_mentors) * num_declarations
      total_payment = total_in_band == 0 ? "0.00" : "119.40"

      within all(".output-payments-table")[1] do
        has_text? "Payment Band A £119.40 #{total_in_band} £#{total_payment}"
      end
    end

    def declaration_in_band?(declarations, band)
      declarations.group_by(&:itself).transform_values(&:size).all? do |declaration_type, num_declarations|
        row_label = table_row_label_for(declaration_type)
        output_payments_table.cell(row_label, band).has_text?(num_declarations)
      end
    end

    def can_see_adjustments_table?(num_ects, num_mentors)
      num_participants = num_ects + num_mentors
      total_payment    = num_participants == 0 ? "0.00" : "100.00"

      adjustments_table.cell("Uplift fee", "Number of trainees").has_text?(num_participants) &&
        adjustments_table.cell("Uplift fee", "Payments").has_text?(total_payment)
    end

    def table_row_label_for(declaration_type)
      declaration_type == :started ? "Starts" : declaration_type.humanize
    end
  end
end
