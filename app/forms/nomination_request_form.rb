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

  def save!
    if valid?(:save)
      ActiveRecord::Base.transaction do
        # TODO: Send an email with a magic link, make sure magic link expires, have a check for too many emails
      end
    end
  end
end
