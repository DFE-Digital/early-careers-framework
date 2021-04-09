# frozen_string_literal: true

class InductionCoordinatorProfile < BaseProfile
  belongs_to :user
  has_and_belongs_to_many :schools

  def self.create_induction_coordinator(full_name, email, school, start_url)
    ActiveRecord::Base.transaction do
      user = User.create!(full_name: full_name, email: email)
      InductionCoordinatorProfile.create!(user: user, schools: [school])
      SchoolMailer.nomination_confirmation_email(user: user, school: school, start_url: start_url).deliver_now
    end
  end
end
