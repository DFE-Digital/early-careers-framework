# frozen_string_literal: true

class Heading
  include ActiveModel::Model
  attr_accessor :name, :declaration, :target, :ects, :mentors, :participants

  def initialize(params)
    params.each do |param, value|
      send("#{param}=", value)
    end
  end
end
