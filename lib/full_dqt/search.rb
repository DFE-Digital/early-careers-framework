# frozen_string_literal: true

require_relative "record"

module FullDQT
  class Search
    def call
      magic_response || dqt_record
    end

    # all matches
    def magic_response_1900_01_01
      FullDQT.magic_record(date_of_birth:, trn:, nino:, full_name:)
    end

    # name and nino don't match
    def magic_response_1900_01_02
      FullDQT.magic_record(date_of_birth:, trn:, nino: nino.to_s.next, full_name: full_name.to_s.next)
    end

    # did not match
    def magic_response_1900_01_03
      FullDQT::Record.new({})
    end

    # matched but no QTS
    def magic_response_1900_01_04
      FullDQT.magic_record(date_of_birth:, trn:, nino:, full_name:, qts_date: nil)
    end

    # matched but no induction
    def magic_response_1900_01_05
      FullDQT.magic_record(date_of_birth:, trn:, nino:, full_name:, induction_start_date: nil)
    end

    # matched but active flags
    def magic_response_1900_01_06
      FullDQT.magic_record(date_of_birth:, trn:, nino:, full_name:, active_alert: true)
    end

    # all matches 2021 cohort start date
    def magic_response_1900_01_21
      FullDQT.magic_record(date_of_birth:, trn:, nino:, full_name:, induction_start_date: Date.new(2021, 9, 1))
    end

    # all matches 2022 cohort start date
    def magic_response_1900_01_22
      FullDQT.magic_record(date_of_birth:, trn:, nino:, full_name:, induction_start_date: Date.new(2022, 9, 1))
    end

    # all matches 2023 cohort start date
    def magic_response_1900_01_23
      FullDQT.magic_record(date_of_birth:, trn:, nino:, full_name:, induction_start_date: Date.new(2023, 9, 1))
    end

  private

    attr_reader :date_of_birth, :trn, :nino, :full_name

    def initialize(date_of_birth:, trn: nil, nino: nil, full_name: nil)
      @trn = trn
      @date_of_birth = date_of_birth
      @nino = nino
      @full_name = full_name
    end

    def dqt_record
      FullDQT::Client.new.get_record(trn:, birthdate: date_of_birth, nino:)
    end

    def magic_response
      return unless Rails.env.development? || Rails.env.deployed_development?

      try("magic_response_#{date_of_birth.to_s.underscore}".to_sym)
    end
  end
end
