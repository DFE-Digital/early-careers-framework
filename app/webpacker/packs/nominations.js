import accessibleAutocomplete from "accessible-autocomplete";

const locationSelect = document.querySelector(".js-location-select");

if (locationSelect) {
  accessibleAutocomplete.enhanceSelectElement({
    selectElement: locationSelect,
  });
}

const schoolSelect = document.querySelector(".js-school-select");

if (schoolSelect) {
  accessibleAutocomplete.enhanceSelectElement({
    selectElement: schoolSelect,
  });
}
