# frozen_string_literal: true

class ServiceFeeCollection
  include ActiveModel
  attr_accessor :service_fees

  %i[participants monthly].each do |summation|
    define_method summation do
      service_fees.map(&summation).inject(&:+)
    end
  end

  private

  def initialize(params)
    self.service_fees=params.map {|service_fee| ServiceFee.new(service_fee)}
  end
end
