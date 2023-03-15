## Listing participant declaration submissions 
This is how you see all the declarations you have made. This functionality allows the provider to check declaration submissions and identify any that are missing.

If declarations are missing, following other guidance by going to <a href="#declaring-that-an-ecf-participant-has-started-their-course" class="govuk-link">Declaring that an <%= programme %> participant started their course

### Checking all previously submitted declarations
This section lets you review all of the declarations you have made.

All of your submitted declarations are listed.

`GET /api/v1/participant-declarations`

This returns [participant declarations](/api-reference/reference-v1#schema-participantdeclarationresponse).

### Checking a single previously submitted declaration 

This section lets you review a single declaration you have made.

`GET /api/v1/participant-declarations/{id}`

This returns a [participant declaration](/api-reference/reference-v1#schema-singleparticipantdeclarationresponse).