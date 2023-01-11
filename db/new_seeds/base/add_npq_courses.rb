# frozen_string_literal: true

[
  {
    id: "15c52ed8-06b5-426e-81a2-c2664978a0dc",
    name: "NPQ Leading Teaching (NPQLT)",
    identifier: "npq-leading-teaching",
  },
  {
    id: "7d47a0a6-fa74-4587-92cc-cd1e4548a2e5",
    name: "NPQ Leading Behaviour and Culture (NPQLBC)",
    identifier: "npq-leading-behaviour-culture",
  },
  {
    id: "29fee78b-30ce-4b93-ba21-80be2fde286f",
    name: "NPQ Leading Teacher Development (NPQLTD)",
    identifier: "npq-leading-teaching-development",
  },
  {
    id: "a42736ad-3d0b-401d-aebe-354ef4c193ec",
    name: "NPQ for Senior Leadership (NPQSL)",
    identifier: "npq-senior-leadership",
  },
  {
    id: "0f7d6578-a12c-4498-92a0-2ee0f18e0768",
    name: "NPQ for Headship (NPQH)",
    identifier: "npq-headship",
  },
  {
    id: "aef853f2-9b48-4b6a-9d2a-91b295f5ca9a",
    name: "NPQ for Executive Leadership (NPQEL)",
    identifier: "npq-executive-leadership",
  },
  {
    id: "7fbefdd4-dd2d-4a4f-8995-d59e525124b7",
    name: "Additional Support Offer for new headteachers",
    identifier: "npq-additional-support-offer",
  },

  {
    id: "0222d1a8-a8e1-42e3-a040-2c585f6c194a",
    name: "The Early Headship Coaching Offer",
    identifier: "npq-early-headship-coaching-offer",
  },
  {
    id: "66dff4af-a518-498f-9042-36a41f9e8aa7",
    name: "NPQ Early Years Leadership (NPQEYL)",
    identifier: "npq-early-years-leadership",
  },
  {
    id: "829fcd45-e39d-49a9-b309-26d26debfa90",
    name: "NPQ Leading Literacy (NPQLL)",
    identifier: "npq-leading-literacy",
  },
].each do |hash|
  FactoryBot.create(:seed_npq_course, id: hash[:id], name: hash[:name], identifier: hash[:identifier])
end
