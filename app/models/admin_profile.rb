# frozen_string_literal: true

# == Schema Information
#
# Table name: admin_profiles
#
#  id           :uuid             not null, primary key
#  discarded_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :uuid             not null
#
# Indexes
#
#  index_admin_profiles_on_discarded_at  (discarded_at)
#  index_admin_profiles_on_user_id       (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class AdminProfile < BaseProfile
  belongs_to :user

  def self.create_admin(full_name, email, sign_in_url)
    user = User.new(full_name: full_name, email: email)

    ActiveRecord::Base.transaction do
      user.confirm
      user.save!
      AdminProfile.create!(user: user)
      AdminMailer.account_created_email(user, sign_in_url).deliver_now
    end
  end
end
