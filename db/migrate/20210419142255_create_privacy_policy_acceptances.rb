class CreatePrivacyPolicyAcceptances < ActiveRecord::Migration[6.1]
  class PrivacyPolicy < ActiveRecord::Base
  end

  class User < ActiveRecord::Base
  end

  class PrivacyPolicyAcceptance < ActiveRecord::Base
    belongs_to :user
    belongs_to :privacy_policy
  end

  def change
    create_table :privacy_policy_acceptances do |t|
      t.uuid :privacy_policy_id
      t.uuid :user_id

      t.index %i(privacy_policy_id user_id), unique: true, name: 'single-acceptance'
      t.timestamps
    end

    reversible do |dir|
      dir.up do
        policies = Hash.new do |hash, version|
          hash[version] = PrivacyPolicy.find_by(version: version)
        end

        User.where.not(privacy_policy_acceptance: nil).find_each do |user|
          PrivacyPolicyAcceptance.create(
            privacy_policy: policies[user.privacy_policy_acceptance["version"]],
            user: user,
            created_at: user.privacy_policy_acceptance['accepted_at'],
            updated_at: user.privacy_policy_acceptance['accepted_at'],
          )
        end
      end

      dir.down do
        User.reset_column_information

        PrivacyPolicyAcceptance.includes(:user, :privacy_policy).find_each do |ppa|
          ppa.user.update(
            privacy_policy_acceptance: {
              version: ppa.privacy_policy.version,
              accepted_at: ppa.created_at
            }
          )
        end
      end
    end

    remove_column :users, :privacy_policy_acceptance, :json
  end
end
