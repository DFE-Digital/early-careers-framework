# frozen_string_literal: true

class Finance::Statement::NPQ < Finance::Statement::Base
  DATA = [
    {
      interval: Time.zone.parse("2021-09-01T00:00:00+01:00")..Time.zone.parse("2021-12-25T23:59:59+00:00"),
      name: "payable",
      payment_date: Date.new(2022, 1, 31),
    },
    {
      interval: Time.zone.parse("2021-12-26T00:00:00+00:00")..Time.zone.parse("2022-06-25T23:59:59+00:00"),
      name: "current",
      payment_date: Date.new(2022, 3, 31),
    },
  ].freeze
end
