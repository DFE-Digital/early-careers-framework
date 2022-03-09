namespace :statements do
  namespace :npq do
    desc "transitions a statements declaration from payable to paid"
    task mark_as_paid: :environment do
      NPQLeadProvider.all.each do |npq_lead_provider|

      end
    end
  end
end
