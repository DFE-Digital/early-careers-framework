# frozen_string_literal: true

class OutputPaymentCollection
  include ActiveModel
  attr_accessor :output_payments

  %i[participants subtotal].each do |summation|
    define_method summation do
      output_payments.map(&summation).inject(&:+)
    end
  end

  private

  def initialize(params)
    self.output_payments=params.map {|service_fee| OutputPayment.new(service_fee)}
  end
end
