<h2 class="app-contents-list__title">Contents</h2>

<ol class="app-contents-list__list">
  <li class="app-contents-list__list-item app-contents-list__list-item--parent"><a class="govuk-link app-contents-list__link" href="#continuing-the-registration-process">Continuing the registration process</a></li>
  <li class="app-contents-list__list-item app-contents-list__list-item--parent"><a class="govuk-link app-contents-list__link" href="#completing-the-registration-process">Completing the registration process</a></li>
  <li class="app-contents-list__list-item app-contents-list__list-item--parent"><a class="govuk-link app-contents-list__link" href="#declaring-that-a-participant-has-started-their-induction">Declaring that a participant has started their induction</a></li>
  <li class="app-contents-list__list-item app-contents-list__list-item--parent"><a class="govuk-link app-contents-list__link" href="#voiding-a-participant-declaration">Voiding a participant declaration</a></li>
  <li class="app-contents-list__list-item app-contents-list__list-item--parent"><a class="govuk-link app-contents-list__link" href="#changing-a-previous-participant-declaration">Changing a previous participant declaration</a></li>
</ol>

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

## Completing the registration process

This scenario begins when a participant has been fully onboarded by the Provider and they are in a position to start their training.

### 1. Provider confirms completion of registration process

Confirm a participant is ready to start their training.

```
POST /api/v1/... TBC
```

With a [request body containing confirmation details](/lead-providers/guidance/reference).

This returns [Success](/lead-providers/guidance/reference).

See [confirm registration complete](/lead-providers/guidance/reference) endpoint.

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

## Voiding a participant declaration

This scenario begins after a participant declaration has been submitted and an identifier for the participant declaration was collected.

### 1. Provider voids a participant because it was made in error

Confirm a participant declaration was submitted in error or with incorrect details.

```
POST /api/v1/participant_declarations/{id}/void
```

With a [request body containing a void participant declaration](/lead-providers/guidance/reference#voidparticipantdeclaration-object).

This returns [participant declaration voided](/lead-providers/guidance/reference#participantdeclarationvoidedresponse-object).

See [void participant declarations](/lead-providers/guidance/reference#post-api-v1-void-participant-declarations) endpoint.

## Changing a previous participant declaration

This scenario begins after a participant declaration has been submitted with incorrect details and an identifier for the participant declaration was collected.

### 1. Provider voids a participant declaration because it is incorrect

Confirm a participant declaration was submitted in error or with incorrect details.

```
POST /api/v1/participant_declarations/{id}/void
```

With a [request body containing a void participant declaration](/lead-providers/guidance/reference#voidparticipantdeclaration-object).

This returns [participant declaration voided](/lead-providers/guidance/reference#participantdeclarationvoidedresponse-object).

See [void participant declarations](/lead-providers/guidance/reference#post-api-v1-void-participant-declarations) endpoint.

### 2. Provider reconfirms a participant has started with correct details

Confirm a participant has started their induction training before Milestone 1.

```
POST /api/v1/participant_declarations
```

With a [request body containing a participant declaration](/lead-providers/guidance/reference#participantdeclaration-object).

This returns [participant declaration recorded](/lead-providers/guidance/reference#participantdeclarationrecordedresponse-object).

See [confirm participant declarations](/lead-providers/guidance/reference#post-api-v1-participant-declarations) endpoint.

### 3. Provider records the new participant declaration id

Store the returned participant declaration id for future management tasks.

