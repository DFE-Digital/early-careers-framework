class PopulateIdentities < ActiveRecord::Migration[6.1]
  class Identity < ApplicationRecord
    belongs_to :user
  end

  class User < ApplicationRecord
    has_many :participant_identities
  end

  class ParticipantIdentity < ApplicationRecord
    belongs_to :user
  end

  def up
    ParticipantIdentity.find_each do |pi|
      Identity.find_or_create_by!(pi.attributes)
    end

    User.where.not(id: ParticipantIdentity.select(:external_identifier)).find_each do |user|
      Identity.find_or_create_by!(user: user, email: user.email)
    end
  end

  def down
    Identity.destroy_all
  end
end
