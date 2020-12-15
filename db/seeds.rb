# frozen_string_literal: true

# TODO: Remove network and school seeding when we have a way of getting them from GIAS
unless Network.first
  network = Network.create!(name: "Test school network")
  network_domain = SchoolDomain.create!(domain: "network.com")
  School.create!(urn: "TEST_URN_1", name: "Test school one", address_line1: "Test address", country: "England", postcode: "TEST1", network: network, school_domains: [SchoolDomain.create(domain: "testschool1.sch.uk"), network_domain])
  School.create!(urn: "TEST_URN_2", name: "Test school two", address_line1: "Test address London", country: "England", postcode: "TEST2", network: network, school_domains: [SchoolDomain.create(domain: "testschool2.sch.uk"), network_domain])
  School.create!(urn: "TEST_URN_3", name: "Test school three", address_line1: "Test address Oxford", country: "England", postcode: "TEST3", school_domains: [SchoolDomain.create(domain: "testschool3.sch.uk")])
  School.create!(urn: "TEST_URN_4", name: "Test school four", address_line1: "Test address Newcastle", country: "England", postcode: "TEST4", school_domains: [SchoolDomain.create(domain: "testschool4.sch.uk")])
end

# TODO: Remove this when we have a way of adding lead providers, or expand to include all of them
unless LeadProvider.first
  LeadProvider.create!(name: "Test Lead Provider")
end
