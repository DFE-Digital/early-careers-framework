## Contents

- [Continuing the registration process](#continuing-the-registration-process)
- [Declaring that a participant has started their induction](#declaring-that-a-participant-has-started-their-induction)

<hr class="govuk-section-break govuk-section-break--visible govuk-!-margin-top-6 govuk-!-margin-bottom-6">

The scenarios on this page show example request URLs and payloads clients can use to take actions via this API. The examples are only concerned with business logic and are missing details necessary for real-world usage. For example, authentication is completely left out.

## Continuing the registration process

This scenario begins when a participant has been added to the service by a school induction tutor via the manage training for early career teachers service.

### 1. Provider retrieves participant records

Get the participant records.

```
GET /api/v1/participants
```

This will return [multiple participant records](/lead-providers/guidance/reference#multipleparticipantresponse-object).

See [retrieve multiple participants](/lead-providers/guidance/reference#get-api-v1-participants) endpoint.

### 2. Participant enters registration details on register for early career framework service

Participant is invited to continue their registration by validating their TRN and contact details.

When the participant has completed this step the participant record will show;

- whether the email address has been validated
- whether the TRN is valid
- whether the participant has achieved QTS status
- whether the participant is eligible for funding

### 3. Provider refreshes participant records

Get updated participant records.

```
GET /api/v1/participants?filter={updated_since:"2021-05-13T11:21:55Z"}
```

This will return [multiple participant records](/lead-providers/guidance/reference#multipleparticipantresponse-object) with the updates to the record included.

See [retrieve multiple participants](/lead-providers/guidance/reference#get-api-v1-participants) endpoint.

## Declaring that a participant has started their induction

This scenario begins after it has been confirmed that a participant is ready to begin their induction training.

### 1. Provider confirms a participant has started

Confirm a participant has started their induction training before Milestone 1.

```
POST /api/v1/participant_declarations
```

With a [request body containing a participant declaration](/lead-providers/guidance/reference#participantdeclaration-object).

This returns [participant declaration recorded](/lead-providers/guidance/reference#participantdeclarationrecordedresponse-object).

See [confirm participant declarations](/lead-providers/guidance/reference#post-api-v1-participant-declarations) endpoint.

### 2. Provider records the participant declaration id

Store the returned participant declaration id for future management tasks.

