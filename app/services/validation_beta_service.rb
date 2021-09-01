# frozen_string_literal: true

class ValidationBetaService
  def invite_schools(array_of_urns:, participant_research:, coordinator_research:)
    School.where(urn: array_of_urns).find_each do |school|
      induction_coordinator = school.induction_coordinators.first
      if induction_coordinator.induction_coordinator_and_mentor?
        participant_profiles = school.active_ecf_participant_profiles.where.not(id: induction_coordinator.mentor_profile.id)
        ActiveRecord::Base.transaction do
          FeatureFlag.activate(:participant_validation, for: school)
          send_induction_coordinator_notification(participant_research, school)
          invite_coordinator_and_mentor(induction_coordinator, school, coordinator_research)
          invite_participants(participant_profiles, school, participant_research)
        end
      else
        ActiveRecord::Base.transaction do
          FeatureFlag.activate(:participant_validation, for: school)
          send_induction_coordinator_notification(participant_research, school)
          invite_participants(school.active_ecf_participant_profiles, school, participant_research)
        end
      end
    end
  end

  def notify_induction_coordinators_about_validation
    School.eligible.find_each do |school|
      if chosen_programme_and_not_in_beta(school)
        send_validation_notification(school)
      end
    end
  end

private

  def participant_validation_start_url
    Rails.application.routes.url_helpers.participants_start_registrations_url(
      host: Rails.application.config.domain,
      **UTMService.email(:participant_validation_beta, :participant_validation_beta),
    )
  end

  def research_url
    Rails.application.routes.url_helpers.page_url(
      page: "user-research",
      host: Rails.application.config.domain,
      **UTMService.email(:participant_validation_research, :participant_validation_research),
    )
  end

  def mentor_research_url
    Rails.application.routes.url_helpers.page_url(
      page: "user-research",
      host: Rails.application.config.domain,
      mentor: true,
      **UTMService.email(:participant_validation_research, :participant_validation_research),
    )
  end

  def coordinator_and_mentor_research_url
    Rails.application.routes.url_helpers.page_url(
      page: "sit-user-research",
      host: Rails.application.config.domain,
      **UTMService.email(:participant_validation_research, :participant_validation_research),
    )
  end

  def induction_coordinator_start_url
    Rails.application.routes.url_helpers.root_url(
      host: Rails.application.config.domain,
      **UTMService.email(:participant_validation_sit_notification),
    )
  end

  def invite_coordinator_and_mentor(user, school, research)
    if research
      ParticipantValidationMailer.coordinator_and_mentor_ur_email(
        recipient: user.email,
        school_name: school.name,
        start_url: participant_validation_start_url,
        user_research_url: coordinator_and_mentor_research_url,
      ).deliver_later
    else
      ParticipantValidationMailer.coordinator_and_mentor_email(
        recipient: user.email,
        school_name: school.name,
        start_url: participant_validation_start_url,
      ).deliver_later
    end
  end

  def invite_participants(profiles, school, research)
    school_cohort = school.school_cohorts.find_by(cohort: Cohort.current)
    if school_cohort&.full_induction_programme?
      invite_fip_participants(profiles, school, research)
    elsif school_cohort&.core_induction_programme?
      invite_cip_participants(profiles, school)
    end
  end

  def invite_fip_participants(profiles, school, research)
    return invite_fip_participants_for_research(profiles, school) if research

    profiles.each do |profile|
      if profile.ect?
        ParticipantValidationMailer.ect_email(
          recipient: profile.user.email,
          school_name: school.name,
          start_url: participant_validation_start_url,
        ).deliver_later
      elsif profile.mentor?
        ParticipantValidationMailer.fip_mentor_email(
          recipient: profile.user.email,
          school_name: school.name,
          start_url: participant_validation_start_url,
        ).deliver_later
      end
    rescue StandardError
      logger.info "Error sending participant validation email to: #{profile&.user&.email} ... skipping"
    end
  end

  def invite_fip_participants_for_research(profiles, school)
    profiles.each do |profile|
      if profile.ect?
        ParticipantValidationMailer.ect_ur_email(
          recipient: profile.user.email,
          school_name: school.name,
          start_url: participant_validation_start_url,
          user_research_url: research_url,
        ).deliver_later
      elsif profile.mentor?
        ParticipantValidationMailer.fip_mentor_ur_email(
          recipient: profile.user.email,
          school_name: school.name,
          start_url: participant_validation_start_url,
          user_research_url: mentor_research_url,
        ).deliver_later
      end
    rescue StandardError
      logger.info "Error sending participant validation email to: #{profile&.user&.email} ... skipping"
    end
  end

  def invite_cip_participants(profiles, school)
    profiles.each do |profile|
      if profile.ect?
        ParticipantValidationMailer.ect_email(
          recipient: profile.user.email,
          school_name: school.name,
          start_url: participant_validation_start_url,
        ).deliver_later
      elsif profile.mentor?
        invite_cip_mentor(profile, school)
      end
    rescue StandardError
      logger.info "Error sending participant validation email to: #{profile&.user&.email} ... skipping"
    end
  end

  def invite_cip_mentor(profile, school)
    if in_engage_beta?(profile)
      ParticipantValidationMailer.engage_beta_mentor_email(
        recipient: profile.user.email,
        school_name: school.name,
        start_url: participant_validation_start_url,
      ).deliver_later
    else
      ParticipantValidationMailer.cip_mentor_email(
        recipient: profile.user.email,
        school_name: school.name,
        start_url: participant_validation_start_url,
      ).deliver_later
    end
  end

  def in_engage_beta?(profile)
    ENGAGE_BETA_PARTICIPANT_USER_IDS.include?(profile.user.id)
  end

  def send_induction_coordinator_notification(participant_research, school)
    if participant_research
      ParticipantValidationMailer.induction_coordinator_ur_email(
        recipient: school.contact_email,
        school_name: school.name,
        start_url: induction_coordinator_start_url,
      ).deliver_later
    else
      ParticipantValidationMailer.induction_coordinator_email(
        recipient: school.contact_email,
        school_name: school.name,
        start_url: induction_coordinator_start_url,
      ).deliver_later
    end
  end

  def send_validation_notification(school)
    ParticipantValidationMailer.induction_coordinator_validation_notification_email(
      recipient: school.contact_email,
      start_url: induction_coordinator_start_url,
    ).deliver_later
  end

  def chosen_programme_and_not_in_beta(school)
    !FeatureFlag.active?(:participant_validation, for: school) && school.chosen_programme?(Cohort.current)
  end

  ENGAGE_BETA_PARTICIPANT_USER_IDS = %w[a4b9d0ad-36df-4291-8c1d-f9d01b44e0ff 53824c21-4582-4e6e-9e71-a45f97d946ca c51fa22c-32c7-442a-b8fb-a2e1c0d1e882 c482acd1-1280-45d2-806e-06339acc7ff4 7544d3fa-5ba9-4c0a-8022-12e857a9a8f0 cef86ca6-8f67-4f3c-bdb4-ed89e9aeaa3a f2272e9c-32ea-4a20-9205-4f6b0bdfbd67 d1d6acbf-1a03-4ca6-8d9e-c8880ae19bb0 4eec2d2c-bfcc-420a-bca7-ac27e3f05845 eeefc4fe-3f93-41e2-8318-e70f4ac7b0ff 554a8c99-814f-4688-b903-001f1d2c2995 fda7e4b5-beab-4558-842c-3c75a98ebacd c1388a8c-d87e-4e52-b952-8f58751b4945 b9fdb421-c625-426c-aa18-1a658484796c 78b43727-95c1-47a3-80e6-b814d2b2a053 9246572b-cf58-437e-87de-3f2b8a89d8e9 a9107321-fc06-49ac-994f-bea1680f83e7 c09ba90e-b203-4aac-bfd7-f8336ea98fa5 c0b336d6-2217-4a4c-b896-383cd612ae44 d264b819-f966-4d40-96c7-d6c4884cd755 c8709ef0-6ac4-4ba0-9e44-f93f2ac87b92 dff8e73a-6dc5-413a-b6f8-e6da28758d1a ebc3b303-8e5f-49fc-aaad-f74c360ba997 d3621202-8ae4-481c-95e4-c54e2b1322e5 b4f7ab45-04bc-408d-a8bc-7c6757321226 b9558596-61d2-41c6-a594-69bb8d606056 f856d15e-898e-45a8-a766-dc15cdb8a3d3 888cee71-f6a8-4552-acd0-9d2cbf4b5ff5 be9f0b1a-2028-450d-8d99-c1419fd1c247 b5449380-d2e4-4d1d-9046-e93aa1ce2617 c4ebbeeb-ba25-4639-884e-a7ee7d1e01bb dc925264-f782-48b7-a67d-c465bf033309 ae6800ae-03e4-4ba9-ab53-34386d21f25b f21cd0bd-0079-4cc4-a812-e2d8f5506fc9 cf973b7e-fdc6-431a-83cf-5149d5a30e0b bc1b505a-a347-49aa-80ec-54c19e2d9443 b6f4bd94-7904-4163-bf4f-ac0ea896190e fd982822-37e5-4b64-bf69-e99b59be18e2 8be0c499-5c84-4ab9-99e8-b8f82fb53160 7a88d3b9-c89c-4205-acd3-44aa7400a211 b81d1ae2-2bbf-4870-8f9d-885877cdb3f7 a633b966-9431-4974-b394-1c924db065a1 b9577a7f-cc24-42f3-a5c0-96eadbab928b cd79e187-ef05-4f08-8d8f-b0992d33bbf3 b40aac21-8ef5-4f84-898f-b126d69e7712 fbc03d05-8dc3-4e62-b45a-f3201ccabafc 6e17a781-bc5a-4d15-8eb2-bf8bc712c71e 8a687756-59d8-4894-ba5e-167f889046ba 8101fd8f-5ed4-4018-bc14-23ea9047bb62 5a6698be-848e-42e3-89c8-e91810ceda1c 6cff21a0-a0e1-4a55-a645-d3f2b5ca56d2 024016be-c7ca-4dd4-b481-536e67c60e5e 084086df-672f-43df-88c8-3f1d3af0c9fd ee1c27fc-57b9-4238-b306-fd2ff6887e02 ccb025e2-dcb4-4245-a939-794768091474 0fe3d7f9-da2b-4aad-98e9-9770f9d05b0d cb6e646e-1255-4dac-88cc-464f6eef1a7c 0af2bc1b-5ef9-496f-adce-951cc4ce68b5 6296c374-37d5-46c5-9979-cdc88163972f be8a41ba-9a89-41b7-8511-91d52578a7d8 3c095ba7-549a-45b7-abcc-58082ea6f78d 357aa259-dd0c-4119-81d7-bb31284c2499 f2a43323-aae5-4e03-b650-16d6722696d3 4656d635-b367-4844-a00e-0cf1c0d323e8 96f34b43-d506-410e-95fe-cc746f3fbedc 1c28101f-813e-4970-83ad-21e70958541e 98a3f9e6-e87b-4a91-8756-e8956f32b6cc 9d9a36e6-6f9e-46a4-9274-cc75e293dcd6 540a52b8-af01-4959-976b-5868e2fcb722 7efbd515-d96f-4617-9b78-15fea685ed85 efb28139-73a0-436c-8199-eecc7fb4fb42 eea76d74-d3da-4293-9100-ff30e08b513c 05546ace-9560-4f9c-8106-1eaaeedd49e8 b37f4f43-91a3-42cc-843d-d1cff87ab02e a6c5e57d-6993-49ea-bb8a-e50632a65808 cc8c761e-af6c-4dee-b33e-a3a5ac44c273 a8701f7b-79f0-4d5c-8d3d-4ff272b9e9f6 8b93d983-ea7e-48e2-b47d-3ed6d08af29b 8af466d6-4fad-40cc-a626-e3ad9f4478b5 895f0dc6-9021-4959-bae8-45bba93b08e6 3433c7c0-03c5-4ad0-8bf4-5a6231ba0427 5014a863-8db0-4126-ae9b-d89fddb9cab5 3638b55d-d867-446a-b366-f5d337c47a16 15e5e721-3421-4d35-8c21-9caecf4a5114 75ecaab6-780f-40f4-9e6b-2abf6fee99a1 8245170d-e2a6-4989-b767-cc6523826632 c28ec2d9-0d4e-45b5-94c1-45d79ab0a908 1a3bdde0-4e07-4139-ad5d-e050286b011d f5f59802-fc48-438f-b7d4-c96836936503 ed88fc68-92a5-497b-bcb0-5f54d19d0210 2faf143e-f849-435e-878e-1afac18f92fe 6598cd28-4165-44bf-8045-3e615fc00c2b 1ebc00c8-5235-4034-927f-20513065213d 4b999cba-36ab-4c23-b346-cec2927fb279 25176642-afe7-4a4f-8428-e03940c781ef 898d7437-b7d5-4163-b8ec-5674be29f5eb 3050fabf-f3eb-42c1-9006-cd53bd6f28ad be65735d-7b33-451a-bb89-74f746079a0b b53d9f13-8c76-458a-bb8e-02d8ac80ca62 b8d1d8be-b84a-4e92-ba1c-22c51e7b9be8 853ff3e1-31f9-4ac7-9db8-20970e6b73aa 34343857-3f8a-4f2c-888f-b91522c7f744 b7990c3c-46e9-4751-9dfe-c95e63d2ce58 2fe0b2ab-f149-44f2-90bb-a51b46ff1234 5bd56f03-c963-46e3-ae30-60412648185e d52bc250-fc40-4a75-bffd-709c24c1866a b37caa87-7891-4ee7-a211-84cbe4ef0d22 36049a75-5c7c-4a64-849d-972bac8187ea 221a4b41-5c62-4221-9689-7dc7e2238600 9ed0ad27-cb01-49ca-b972-f519a1b30558 968b43e6-cd69-45f5-a86a-7129dae04028 b75289cd-714a-4569-ae3f-819f0b599f66 b852dfd0-cb3d-4701-8e80-de84327f84d3 4b67e98c-b980-4166-bc82-fb8293ee9fe4 c1ffaf24-8dff-4096-951e-7f131771f07d 54751308-acb6-4d79-a7b8-badc97a3212d 4fe62c5c-6670-4211-85e3-11ffc3606b37 5595a04d-f8b3-43b1-a447-a2b2e4b2b2f8 662aed3a-947d-43e8-b2ef-389c50ef6257 1aaa81da-333e-4ec3-9d42-aaedc13d77ed 7ef19434-8fac-4e02-84e4-962eac4ba858 df19dbab-62e6-44fa-b581-4a965641ed1e 14a1ca88-bee0-4ec3-99e0-8994b5fb5be4 4d492d65-941a-49f3-8c68-46dcde06e8cc 6b049848-04df-4bd0-9bc0-39176a542dad b5bee063-4073-4fff-818f-da70073099d1 a22c9263-1763-4678-9254-3148bd68aa98 04184a46-2ac2-465f-8969-7cb011fa966f ac1672b2-bdee-4155-81d5-5b86499ba45c 30843260-c554-4af1-bbfb-5e6a158fe7dd f9eb8fdc-b44e-4a6c-bf3c-01d525d47d79 bb867328-6a1f-424d-b979-0baddfc9635a 8586d9d7-b09a-479d-b0ee-81257686a4bb 58d5b869-5c81-48a3-9803-bccd3b8a7e27 d6a29f1e-103b-43f3-9d06-47a22bc5ad8a d23156a1-118c-4a69-88ff-3e8e817a2100 617bf5bd-f5bf-4d8b-8e07-994706f95ad2 777afe03-530d-45dc-9a0b-14f686312c61 8ed98f3f-eeb7-43d8-93ac-18bcaecc8665 99eb575a-3340-49b3-8657-ce53b7de30f7 bde885a6-6765-4e11-ae9a-ab1829a9e924 e6053fac-bed4-4a2a-bb29-a08631f9efa2 d82483f7-1dfd-427e-bc8d-1c0d82f84858 d6b90358-426f-48ee-adea-4b63b12b25a9 7acc69a4-7545-4670-b61e-fe9e06e1cf73 6ff1359e-dbb8-4c4c-8c73-306579f9db6a 3342fd38-917d-4893-b75b-c475bb860d93 90d61c56-0681-420d-9592-82a43dd2ae53 5e4008c1-4c46-4172-aaee-21fde08edb7a e9f36a83-9b41-46f0-b1d2-d51eae9bc81b 847eb772-5090-44be-b21d-97d5dcd211be d055a11b-7542-4e6c-9a8a-fe690424caa4 5cc1d12e-80ee-45a8-b86b-25e901c189e0 9986ee71-86ec-44ac-91c4-0a2a7e53df38 2a44fe7e-9da4-485c-b712-21907fd2e5b6 37132ffe-1a00-4808-ac0a-640d60a94a8d 0da42e61-c14d-4696-9268-40030144701e 6f2906f0-19a4-4c87-b649-e1659fa87c6b 8b243db6-8625-4f81-8c48-bf5095f41eb9 78823a2f-21e9-4bb9-b291-44e5834dea8e 5f14aab4-82d1-4972-a396-f54a0d2750bf 80b3f42e-4ae3-441d-aa33-f29f3158a675 1269a926-075a-4d0d-95c8-e910d92369a1 0c206ce8-a9ab-4eef-a3b4-5d3319d8db8b 7956caf2-cf07-4356-90f0-a12cf0929d50 5cb9b4b2-de45-435d-a1bb-d48f1a32ae47 9bf558a0-eed8-4c39-b3ab-b1a325e1c782 2de8b20a-63aa-46c4-9df9-a5013dacb8cc c2845363-64b6-4d48-b039-5d7be50ef8d1 bc4bb90d-692c-484b-9138-946ac7aea151 a32589d5-6d57-4f0f-85d8-e0590a31d191 b85ad37a-42ef-4600-a3a8-c84a2cbf0716 573656e3-c011-4d05-9bba-d3b78d00067e c4b95d69-85e1-4afb-a390-8b3a4783bf68 07a8ed58-b463-433e-b75b-d82a42e7ad7a 020757d0-42b9-4f52-8238-c946a9c52626 4f897fea-2402-4bc1-aae2-4b8cf3a8b05b b04f5fda-203c-4b79-9fca-c3e2e3bbc40a 0248df97-ea8e-4a28-9357-547a4574181a 118bc468-397e-43b1-b9d1-8ec1f99dcfe4 18823afd-ea7a-4a92-a7ff-a7c19db568cb 662b8622-b63e-4d34-9c17-dd9ac3c7a635 82e81b8b-676f-4496-9814-6c45901003f0 301434ea-6e7f-4f18-b3c2-39b4384c75df 4443c4de-9717-4ca5-afca-3c179d888bd1 b3a85b10-72d9-4de5-aa39-8d9a9efc1b90 caf28b70-c9f2-41ca-b6eb-a9e0e16bf64e 3839d6a1-4e2b-476a-8dce-6554e56c6b2d 474f71ca-a74b-49ac-9980-092a51dd8c7b 298903fc-50f4-4a7b-a4cd-72bcf3f2d2b9 a78b6b30-7083-4759-9cbc-8b07be2764c3 c1f672be-7cb0-4d73-a92a-fb012518a406 4db0cb24-c2c2-4b04-886b-3cca1a4abd5b f91de327-a4d1-47f0-9ead-6fdf7d7d1cee d92bf1db-6a18-4c71-9319-cfea47ef4c71 2e98814d-0a3b-43df-824c-6733352069e1 bfdea441-8976-444a-b6b1-eda562d13237 5a4c5dd4-b91f-4c59-93cf-73f8d213568d ebbd646a-2baf-470a-ba01-b8f53b015606 48285833-2b86-4645-bc91-5a6451866f1c b49fdb98-ecb4-469f-a25c-d1c4fcbe0b30 2aee5ee6-e117-4b38-924a-e0eb39cfefb1 4e0c9712-ed55-4f39-828a-c14b772b5f10 0723e3a0-ae38-4c74-91ff-ffb0f7be0b76 ac2dc068-9913-4d3d-85c7-17464d667135 4032338b-7fd5-4236-9a7b-da26f2d6d670 63d3edf0-a2cf-4d49-81de-31265023cff3 294242fc-4cae-46da-878a-57be025ef920 1d01cd31-98b0-404a-949f-dc9f19b0f403 f6acfcf7-ed0c-4ad7-a52a-804af76fc0a2 b09b0038-749f-4731-a668-6501c6773e3c ee7acbf0-fe2d-44d1-8b19-cb94ade8b825 4a63b52b-36fc-41c7-8fc5-0407ec705742 34451463-e6ac-4bc6-a58c-d337a7829c42 10f06668-45d9-4dbd-8bf8-7ef758cc955d 054302e9-b8dc-4b85-9359-82268075b388 627c380f-740e-46fc-8b4e-60a0d4cc4084 065ef7da-07ad-4451-a337-4d39bc312fd0 7ae27301-a373-44d1-96e8-3c4adb92d980 cdb3cfe1-8ad6-4c90-9508-8b572ae6dd77 4110ca28-86fb-45c0-8eb8-c7728e7ae553 58a74383-f0ad-4f0b-b3b6-074fd63b763a 4b5eeecd-2ffc-4d5e-b35d-be1d2ab92f39 fcc24f7c-f282-46e5-8bca-319eaa9c7efe f559a4cf-9b9f-47e7-abb8-e5bcc8f16f30 98263507-0d23-49e9-8da7-8984acbabd31 17ab0f2a-ea59-42c9-8d6f-c08ee807b5d0 56472ad9-c867-4906-b54e-4bbb93daaa4f e44c5e26-6c20-42c7-b237-f81f4c457f1d 704c7e5d-3c7c-4ae6-8703-c5235d726143 9f2f73cc-8160-4a69-b2c0-f79ae568e06c 0036ac2f-0190-4133-a5bb-72f5cabdd94c 6d3f2918-46f7-4504-9ef7-9e9920163781 28967e0d-d96e-4a08-9d6d-5c05bdc3fcb0 dd75b2ca-feb5-4e99-b337-8d4b2fc006f5 1ea06eae-4084-476d-8f73-da00260ccce5 467131c4-ac97-4978-bdea-24e0d4715dff cb362245-b75f-4875-8e7f-4462061a58f4 f27afbe0-e0b8-4a83-9be1-fabe942919f4 2672cdbf-74ae-44ce-aace-030cd5493c84 eebc0947-1967-4293-bc16-3172211567e1 fa20b302-abca-4bfc-907d-55dd6ec550da d8e3be2b-703e-4a60-9a1c-0fa7ab13cd02 b878daea-a03c-4058-9a0f-55889f6d3731 59201ec9-7a8e-42c9-ba7a-32a386adb701 5240acd0-5062-46ec-af78-e4b392675796 0a5ba1f0-a394-44d1-b15c-4fb9146da467 7a658fad-7dc2-4c7b-acc6-26da5adf311d efda9eeb-ce0f-4a95-a562-4f917c464302 574d8d29-a00f-4868-986a-3fb00761b180 6a443c4b-ecdb-4044-81ce-9ad13450527d 0c44e272-e754-48a0-bfcf-71128f1432cf 0e13eaaa-9e17-4744-a73a-ff5b5a17846b 7806bbba-677f-4609-b144-5e77bd3b8b30 6ef7f832-5d3f-4274-9bd4-0ddeb6a0c9d1 02a93cce-6743-43ec-b6b7-75e7f7c75316 e0e9d1f2-d44e-40f6-8321-eabee3b57fef 14bb793a-3bf9-434e-a469-649f3b63047d fd6122fe-c1d2-497e-b38f-aae5d7a527e1 ec642c92-d3b6-4f4c-93e4-6a1730ad4d59 053fdb73-621c-4951-acfb-7dc910b9f204 6c098796-592a-42f3-aa97-b53ff19b8b18 2e36d4aa-a372-415e-90cb-c688f02f680d f41927b7-c2dd-4e5d-9519-2d49efe3649a 0cda3522-dd3e-439d-a2b3-bde70e14ea1a 4180cd16-2bdb-47f1-8e55-43dbc731f4cf 56dca7b8-9d70-4069-bdd9-55aaa290a88e 4cb7ee43-4361-49fc-9b5f-3de46c8473fd 222f4631-f7d6-461e-a211-654e77a9195f 97e42312-95eb-4043-82c2-ad5d3b8caf1f 8e022e7a-5c29-4089-a193-7499222ce89f 61ffa285-cdd1-49c4-8d5c-8930bc7b0ca3 8ca9c87e-ef12-4acf-8279-c933fdb451da 4916c36b-6821-44d8-a68a-d33abc1f0d94 5708916e-26a4-4af7-af0d-fcd64d242380 37b13bda-4d9c-4e8b-bc20-2966c4008ff9 757a01c6-f281-411d-80af-3b21dc2d9b6a c8c8a440-1022-4025-9484-ef03ee8dbfae bcfad16e-5964-4901-81a7-7f68bb8b9c80 23f42e1e-1ad1-4152-8a6b-4214902e0d9e a3f4fe79-4e92-4a83-890b-2dbda6fe0439 8672be23-e5fb-4787-a073-e563715c9e84 3663b9a1-cc61-4eb3-a938-d6811c3e4293 1ae00800-dcf6-4421-aff4-79dbdb80cf6b 0e79769b-a449-4feb-9968-62ac93af9359 3b01cc5a-fe20-4b34-848f-d4b08bd95d68 68805f68-0589-4a23-bf50-bcd0ac4aae3e 7eca2622-d9ab-4633-9e18-096181b55ddb f9587c57-8b0b-4e17-8ba1-39c2ed20be93 57379321-2526-471b-beee-e171b70f9ad1 77d5fdcf-83f0-4564-9e34-8f703172fd54 476f884e-2e61-4c87-867d-1c134ff69e3d 89cf5416-cf5c-403a-b11b-fa3a0b7b37cf].freeze
end
