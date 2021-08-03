# frozen_string_literal: true

class OtherFeeCollection
  include ActiveModel::Model
  attr_accessor :other_fees

  %i[participants subtotal].each do |summation|
    define_method summation do
      other_fees.map(&summation).inject(&:+)
    end
  end

  def initialize(params)
    self.other_fees = params.map { |other_fee| OtherFee.new(other_fee) }
  end
end
