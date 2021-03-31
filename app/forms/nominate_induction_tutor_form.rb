# frozen_string_literal: true

class NominateInductionTutorForm
  include ActiveModel::Model

  attr_accessor :full_name, :email, :token

  validates :full_name, presence: { message: "Enter a name" }, on: :details
  validates :email, presence: { message: "Enter email" }, on: :details

  def save!
    school = NominationEmail.find_by(token: token).school
    profile = InductionCoordinatorProfile.new

    user = ActiveRecord::Base.transaction do
      user = User.create!(
        full_name: full_name,
        email: email,
        confirmed_at: Time.zone.now.utc, # Question Should we confirm the user or not?
      )
      profile.user = user
      profile.save!
      school.induction_coordinator_profiles << profile
      user
    end

    UserMailer.tutor_nomination_instructions(user, school.name).deliver_now

    user
  end
end
