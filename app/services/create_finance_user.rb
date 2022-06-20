# frozen_string_literal: true

class CreateFinanceUser < BaseService
  def self.call(full_name, email)
    user = User.new(full_name:, email:)

    ActiveRecord::Base.transaction do
      user.save!
      FinanceProfile.create!(user:)
    end
  end
end
