# frozen_string_literal: true

# this is intended for use with the seed_ecf_participant_eligibilty factory
def random_weighted_eligibility_trait
  {
    eligible: 20,
    ineligible: 4,
    no_qts: 2,
    active_flags: 2,
    different_trn: 1,
    previous_induction: 1,
    previous_participation: 1,
    secondary_profile: 2,
    exempt_from_induction: 2,
  }
    .map
    .with_object([]) { |(trait, weighting), a| weighting.times { a << trait } }
    .sample
end
