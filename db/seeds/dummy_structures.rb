# frozen_string_literal: true

SchoolDataImporter.new(Rails.logger).delay.run

# We clear the database on a regular basis, but we want a stable token that E&L can use in its dev environments
# Hashed token with the same unhashed version will be different between dev and deployed dev
# The tokens below have different unhashed version to avoid worrying about clever cryptographic attacks
if Rails.env.deployed_development?
  EngageAndLearnApiToken.find_or_create_by!(hashed_token: "dfce9a34c6f982e8adb4b903f8b6064682e6ad1f7858c41ed8a0a7468abc8896")
  NpqRegistrationApiToken.find_or_create_by!(hashed_token: "1dae3836ed90df4b796eff1f4a4713247ac5bc8a00352ea46eee621d74cd4fcf")
elsif Rails.env.development?
  EngageAndLearnApiToken.find_or_create_by!(hashed_token: "f4a16cd7fc10918fbc7d869d7a83df36059bb98fac7c82502d797b1f1dd73e86")
end
