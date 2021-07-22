# frozen_string_literal: true

class CreateFinanceUser < BaseService
  def self.call(full_name, email)
    user = User.new(full_name: full_name, email: email)

    ActiveRecord::Base.transaction do
      user.save!
      FinanceProfile.create!(user: user)
    end
  end
end
