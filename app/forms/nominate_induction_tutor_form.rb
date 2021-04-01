# frozen_string_literal: true

class NominateInductionTutorForm
  include ActiveModel::Model

  attr_accessor :full_name, :email, :token

  validates :full_name, presence: { message: "Enter a name" }, on: :details
  validates :email, presence: { message: "Enter email" }, on: :details

  def save!
    school = NominationEmail.find_by(token: token).school

    user = ActiveRecord::Base.transaction do
      user_record = User.create!(
        full_name: full_name,
        email: email,
        confirmed_at: Time.zone.now,
      )

      InductionCoordinatorProfile.create!(user: user_record, schools: [school])
      user_record
    end

    UserMailer.tutor_nomination_instructions(user, school.name).deliver_now

    user
  end
end
