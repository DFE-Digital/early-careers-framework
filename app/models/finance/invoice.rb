# frozen_string_literal: true

class Finance::Invoice
  DATA = [
    {
      interval: Time.zone.parse("2021-09-01T00:00:00+01:00")..Time.zone.parse("2021-11-19T23:59:59+00:00"),
      name: "payable",
      payment_date: Date.new(2021, 11, 30),
    },
    {
      interval: Time.zone.parse("2021-11-20T00:00:00+00:00")..Time.zone.parse("2022-01-31T23:59:59+00:00"),
      name: "current",
      payment_date: Date.new(2022, 2, 28),
    },
  ].freeze

  def self.all
    DATA.map do |hash|
      new(
        interval: hash[:interval],
        name: hash[:name],
        payment_date: hash[:payment_date],
        deadline_date: hash[:interval].end.to_date,
      )
    end
  end

  def self.find_by_name(name)
    all.find { |i| i.name == name }
  end

  attr_reader :interval, :name, :payment_date, :deadline_date

  def initialize(interval:, name:, payment_date:, deadline_date:)
    @interval = interval
    @name = name
    @payment_date = payment_date
    @deadline_date = deadline_date
  end
end
