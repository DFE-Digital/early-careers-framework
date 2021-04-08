# frozen_string_literal: true

class NominationRequestForm
  include ActiveModel::Model
  include ActiveModel::Serialization

  attr_accessor :local_authority_id, :school_id
  validates :local_authority_id,
            presence: { message: "The details you entered do not match any establishments" },
            on: %i[local_authority save]
  validates :school_id,
            presence: { message: "The details you entered do not match any establishments" },
            on: %i[school save]

  def attributes
    { local_authority_id: nil, school_id: nil }
  end

  def available_schools
    School.open.joins(:school_local_authorities).where(school_local_authorities: { local_authority_id: local_authority_id })
  end

  def school
    School.find(school_id)
  end

  def email_limit_reached?
    invite_schools_service.sent_email_recently?(school)
  end

  def save!
    if valid?(:save)
      ActiveRecord::Base.transaction do
        raise TooManyEmailsError if email_limit_reached?

        invite_schools_service.run([school.urn])
      end
    end
  end

private

  def invite_schools_service
    @invite_schools_service ||= InviteSchools.new
  end
end

class TooManyEmailsError < StandardError; end
