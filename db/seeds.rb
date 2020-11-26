# TODO: Remove network and school seeding when we have a way of getting them from GIAS

network = Network.create!(name: "Test school network")

School.create!(urn: "TEST_URN_1", name: "Test school one", address: "Test address", network: network)
School.create!(urn: "TEST_URN_2", name: "Test school two", address: "Test address London")
School.create!(urn: "TEST_URN_3", name: "Test school three", address: "Test address Oxford")
School.create!(urn: "TEST_URN_4", name: "Test school four", address: "Test address Newcastle")

# TODO: Remove this when we have a way of adding lead providers, or expand to include all of them
LeadProvider.create!(name: "Test Lead Provider")
