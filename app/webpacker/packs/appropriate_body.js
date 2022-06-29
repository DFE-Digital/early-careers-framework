import accessibleAutocomplete from "accessible-autocomplete";

const appropriateBodySelect = document.querySelector(
  "#schools-setup-school-cohort-form-appropriate-body-field"
);

if (appropriateBodySelect) {
  accessibleAutocomplete.enhanceSelectElement({
    selectElement: appropriateBodySelect,
  });
}
