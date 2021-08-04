# frozen_string_literal: true

namespace :data do
  namespace :privacy_policy do
    desc "Stores the content of data/privacy_policy.html file as the next minor privacy policy version"
    task minor: :environment do
      current = PrivacyPolicy.current
      policy_content = Rails.root.join("data/privacy_policy.html").read

      if current.html == policy_content
        puts "There are no changes to publish - version #{current.version} is already up to date"
      else
        policy = PrivacyPolicy.create!(
          major_version: current.major_version,
          minor_version: current.minor_version + 1,
          html: policy_content,
        )

        puts "Privacy policy version #{policy.version} successfully published"
      end
    end

    desc "Stores the content of data/privacy_policy.html file as the next major privacy policy version"
    task major: :environment do
      current = PrivacyPolicy.current
      policy_content = Rails.root.join("data/privacy_policy.html").read

      # We check for minor version as we might want to republish the current version of policy as major even if it was previously published as minor
      if current.minor_version.zero? && current.html == policy_content
        puts "There are no changes to publish - version #{current.version} is already up to date"
      else
        policy = PrivacyPolicy.create!(
          major_version: current.major_version + 1,
          minor_version: 0,
          html: policy_content,
        )

        puts "Privacy policy version #{policy.version} successfully published"
      end
    end
  end
end
