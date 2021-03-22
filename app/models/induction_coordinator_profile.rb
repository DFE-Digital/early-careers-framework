# frozen_string_literal: true

# == Schema Information
#
# Table name: induction_coordinator_profiles
#
#  id           :uuid             not null, primary key
#  discarded_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :uuid             not null
#
# Indexes
#
#  index_induction_coordinator_profiles_on_discarded_at  (discarded_at)
#  index_induction_coordinator_profiles_on_user_id       (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class InductionCoordinatorProfile < BaseProfile
  belongs_to :user
  has_and_belongs_to_many :schools
end
