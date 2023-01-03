# frozen_string_literal: true

# finally for the smoke tests to work we need to set up some tokens

if Rails.env.deployed_development?
  EngageAndLearnApiToken.find_or_create_by!(hashed_token: "dfce9a34c6f982e8adb4b903f8b6064682e6ad1f7858c41ed8a0a7468abc8896")
  NPQRegistrationApiToken.find_or_create_by!(hashed_token: "1dae3836ed90df4b796eff1f4a4713247ac5bc8a00352ea46eee621d74cd4fcf")
  DataStudioApiToken.find_or_create_by!(hashed_token: "c7123fb0e2aecb17e1089e01849d71665983e200e891fe726341a08f176c1d64")
elsif Rails.env.development?
  EngageAndLearnApiToken.find_or_create_by!(hashed_token: "f4a16cd7fc10918fbc7d869d7a83df36059bb98fac7c82502d797b1f1dd73e86")
end

if Rails.env.sandbox?
  NPQRegistrationApiToken.find_or_create_by!(hashed_token: "166eaa39950ad15f2f36041cb9062cc8fa9f109945fe9b8378bf904fe35369bc")
else
  {
    "Ambition Institute"          => "ambition-token",
    "Best Practice Network"       => "best-practice-token",
    "Capita"                      => "capita-token",
    "Education Development Trust" => "edt-token",
    "Teach First"                 => "teach-first-token",
    "UCL Institute of Education"  => "ucl-token",
  }.each do |name, token|
    cpd_lead_provider = CpdLeadProvider.find_by!(name:)

    LeadProviderApiToken.create_with_known_token!(token, cpd_lead_provider:)
  end
end
