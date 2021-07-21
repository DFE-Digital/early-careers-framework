# frozen_string_literal: true

module Tasks
  class PaymentBreakdown
    attr_accessor :total_participants, :uplift_participants, :contract, :total_ects, :total_mentors, :service_fee_calculator, :output_calculator, :uplift_calculator
    delegate :bands, :recruitment_target, to: :contract

    class << self
      def call(contract:, total_participants:, uplift_participants:, total_ects: 0, total_mentors: 0)
        new(contract: contract, total_participants: total_participants, uplift_participants: uplift_participants, total_ects: total_ects, total_mentors: total_mentors)
      end
    end

    def initialize(contract:, total_participants:, uplift_participants:, total_ects: 0, total_mentors: 0)
      @contract = contract
      @total_participants = total_participants
      @uplift_participants = uplift_participants
      @total_ects = total_ects
      @total_mentors = total_mentors
      @logger = set_up_logger
      @service_fee_calculator = PaymentCalculator::Ecf::ServiceFeesForBand.new({ contract: contract })
      @output_calculator = PaymentCalculator::Ecf::OutputPaymentAggregator.new({ contract: contract })
      @uplift_calculator = PaymentCalculator::Ecf::UpliftCalculation.new({ contract: contract })
    end

    def set_up_logger
      Logger.new($stdout).tap do |logger|
        logger.formatter = proc do |_severity, _datetime, _progname, msg|
          "#{msg}\n"
        end
      end
    end

    def service_fee_per_participant(band)
      service_fee_calculator.send(:service_fee_per_participant, band)
    end

    def service_fee_monthly(band)
      service_fee_calculator.send(:service_fee_monthly, band)
    end

    def output_payment_per_participant(band)
      output_calculator.send(:output_payment_per_participant_for_event, { band: band, event_type: :started })
    end

    def output_payment_total(band)
      output_calculator.send(:output_payment_for_event, { band: band, event_type: :started, total_participants: total_participants })
    end

    # Output helper methods
    def index_to_heading(number)
      ("a".."c").to_a[number]
    end

    def lead_provider_name
      @contract.lead_provider.name
    end

    def as_financial(&blk)
      "£#{number_to_delimited(number_to_rounded(blk.call, precision: 2))}"
    end

    # Table generator methods
    def to_table
      @logger.info headings_table
      @logger.info service_fee_table
      @logger.info output_payment_table
      @logger.info other_fees_table
    end

    def headings_table
      Terminal::Table.new do |t|
        t.title = "Payment breakdown"
        t.rows = [
          ["Provider", lead_provider_name],
          %w[Milestone Started],
          ["Recruitment target", recruitment_target],
          ["Current ECTs", total_ects],
          ["Current mentors", total_mentors],
          ["Current participants", total_participants],
        ]
      end
    end

    def service_fee_table
      Terminal::Table.new do |t|
        t.title = "Service fee"
        t.headings = ["Band", "Number of Participants", "Payment amount per person", "Payment amount monthly"]
        t.rows = (0..2).map do |row|
          band = contract.bands[row]
          [
            index_to_heading(row).upcase,
            band.number_of_participants_in_this_band(recruitment_target),
            as_financial { service_fee_per_participant(band) },
            as_financial { service_fee_monthly(band) },
          ]
        end
        t.style = { alignment: :left }
      end
    end

    def output_payment_table
      Terminal::Table.new do |t|
        t.title = "Output fee"
        t.headings = ["Band", "Number of Participants", "Payment amount per person", "Payment amount for period"]
        t.rows = (0..2).map do |row|
          band = contract.bands[row]
          [
            ("A".."C").to_a[row],
            band.number_of_participants_in_this_band(total_participants),
            as_financial { output_payment_per_participant(band) },
            as_financial { output_payment_total(band) },
          ]
        end
        t.style = { alignment: :left }
      end
    end

    def other_fees_table
      Terminal::Table.new do |t|
        t.title = "Other fees"
        t.headings = ["Fee", "Number of Participants", "Payment amount per person", "Payment amount for period"]
        t.rows = [
          [
            "Uplift fee",
            uplift_participants,
            uplift_calculator.uplift_payment_per_participant,
            uplift_calculator.uplift_payment_for_event(uplift_participants: uplift_participants, event_type: :started),
          ],
        ]
        t.style = { alignment: :left }
      end
    end

    # CSV generator methods
    def csv_headings
      summary_headings + service_fee_headings + output_payment_headings + other_fees_headings
    end

    def csv_body
      summary_values + service_fee_values + output_payment_values + other_fees_values
    end

    def summary_headings
      %w[provider milestone target participants ects mentors band_a band_b band_c]
    end

    def summary_values
      [lead_provider_name, "started", recruitment_target, total_participants, total_ects, total_mentors, bands[0].number_of_participants_in_this_band(total_participants), bands[1].number_of_participants_in_this_band(total_participants), bands[2].number_of_participants_in_this_band(total_participants)]
    end

    def service_fee_headings
      (0..2).map { |row|
        ["band_#{index_to_heading(row)}_per_participant_service_fee", "band_#{index_to_heading(row)}_service_fee_amount"]
      }.flatten
    end

    def service_fee_values
      contract.bands.map { |band|
        [service_fee_per_participant(band), service_fee_monthly(band)]
      }.flatten
    end

    def output_payment_headings
      (0..2).map { |row|
        ["band_#{index_to_heading(row)}_per_participant_output_payment", "band_#{index_to_heading(row)}_output_amount"]
      }.flatten
    end

    def output_payment_values
      contract.bands.map { |band|
        [output_payment_per_participant(band), output_payment_total(band)]
      }.flatten
    end

    def other_fees_headings
      %w[uplift_participants uplift_fee_per_participant uplift_fee_for_period]
    end

    def other_fees_values
      [uplift_participants, uplift_calculator.uplift_payment_per_participant, uplift_calculator.uplift_payment_for_event(uplift_participants: uplift_participants, event_type: :started)]
    end
  end
end
