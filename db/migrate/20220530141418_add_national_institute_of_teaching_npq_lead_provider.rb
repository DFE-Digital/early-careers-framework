# frozen_string_literal: true

class AddNationalInstituteOfTeachingNPQLeadProvider < ActiveRecord::Migration[6.1]
  def change
    niot_name = "National Institute of Teaching"
    niot_id = "3ec607f2-7a3a-421f-9f1a-9aca8a634aeb"
    vat_chargeable = false

    npq_lead_provider = NPQLeadProvider.find_or_create_by!(name: niot_name, id: niot_id, vat_chargeable:)
    cpd_lead_provider = CpdLeadProvider.find_or_create_by!(name: niot_name)
    npq_lead_provider.update!(cpd_lead_provider:)
  end
end
