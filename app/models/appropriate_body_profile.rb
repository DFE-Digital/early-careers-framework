# frozen_string_literal: true

class AppropriateBodyProfile < ApplicationRecord
  has_paper_trail

  belongs_to :user
  belongs_to :appropriate_body

  def self.create_appropriate_body_user(full_name, email, appropriate_body)
    ActiveRecord::Base.transaction do
      user = User.find_or_create_by!(email:) do |u|
        u.full_name = full_name
      end
      abp = AppropriateBodyProfile.create!(user:, appropriate_body:)
      AppropriateBodyProfileMailer.welcome(appropriate_body_profile: abp).deliver_now
    end
  end
end
