# frozen_string_literal: true

class Finance::Statement::ECF < Finance::Statement::Base
  DATA = [
    {
      interval: Time.zone.parse("2021-09-01T00:00:00+01:00")..Time.zone.parse("2021-11-19T23:59:59+00:00"),
      name: "payable",
      payment_date: Date.new(2021, 11, 30),
    },
    {
      interval: Time.zone.parse("2021-11-20T00:00:00+00:00")..Time.zone.parse("2021-12-25T23:59:59+00:00"),
      name: "current",
      payment_date: Date.new(2022, 1, 25),
    },
  ].freeze
end
