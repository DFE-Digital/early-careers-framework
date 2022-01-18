# frozen_string_literal: true

class Finance::Statement::Base
  def self.all
    self::DATA.map do |hash|
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
