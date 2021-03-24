# frozen_string_literal: true

class NominationForm
  include ActiveModel::Model
  include ActiveModel::Serialization

  attr_accessor :local_authority_id, :school_id
  validates :local_authority_id,
            presence: { message: "We could not find any local authorities matching your search criteria" },
            on: %i[local_authority save]
  validates :school_id,
            presence: { message: "We could not find any establishments matching your search criteria" },
            on: %i[school save]

  def attributes
    { local_authority_id: nil, school_id: nil }
  end

  def available_schools
    SchoolLocalAuthority.where(local_authority_id: local_authority_id).joins(:school).includes(:school).map(&:school)
  end

  def school
    School.find(school_id)
  end

  def save!
    if valid?(:save)
      ActiveRecord::Base.transaction do
        # TODO: Send an email with a magic link, make sure magic link expires
      end
    end
  end
end
