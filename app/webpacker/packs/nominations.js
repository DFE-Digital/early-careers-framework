import accessibleAutocomplete from "accessible-autocomplete";

const locationSelect = document.querySelector(
  "[name='nomination_form[local_authority_id]']"
);

if (locationSelect) {
  accessibleAutocomplete.enhanceSelectElement({
    selectElement: locationSelect,
  });
}

const schoolSelect = document.querySelector(
  "[name='nomination_form[school_id]']"
);

if (schoolSelect) {
  accessibleAutocomplete.enhanceSelectElement({
    selectElement: schoolSelect,
  });
}
