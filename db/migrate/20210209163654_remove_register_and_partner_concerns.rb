# frozen_string_literal: true
# rubocop:disable all

class RemoveRegisterAndPartnerConcerns < ActiveRecord::Migration[6.1]
  def change
    remove_reference :cohorts_lead_providers, :cohort
    remove_reference :cohorts_lead_providers, :lead_provider
    remove_reference :delivery_partner_profiles, :delivery_partner
    remove_reference :delivery_partner_profiles, :user
    remove_reference :early_career_teacher_profiles, :school
    remove_reference :lead_provider_cips, :cohort
    remove_reference :lead_provider_cips, :core_induction_programme
    remove_reference :lead_provider_cips, :lead_provider
    remove_reference :lead_provider_profiles, :lead_provider
    remove_reference :lead_provider_profiles, :user
    remove_reference :partnerships, :lead_provider
    remove_reference :partnerships, :school
    remove_reference :provider_relationships, :cohort
    remove_reference :provider_relationships, :delivery_partner
    remove_reference :provider_relationships, :lead_provider
    remove_reference :schools, :local_authority
    remove_reference :schools, :local_authority_district
    remove_reference :schools, :network

    drop_table :schools
    drop_table :provider_relationships
    drop_table :partnerships
    drop_table :networks
    drop_table :local_authority_districts
    drop_table :local_authorities
    drop_table :lead_providers
    drop_table :lead_provider_profiles
    drop_table :lead_provider_cips
    drop_table :induction_coordinator_profiles_schools
    drop_table :delivery_partners
    drop_table :delivery_partner_profiles
    drop_table :cohorts_lead_providers
  end
end
# rubocop:enable all
