import accessibleAutocomplete from "accessible-autocomplete";

const searchEl = document.querySelector("#location-autocomplete");

if (searchEl) {
  accessibleAutocomplete({
    element: searchEl,
    id: "autocomplete-location-field",
    source: ["here", "there"],
    showNoOptionsFound: false,
    minLength: 1,
    name: searchEl.dataset.inputName,
  });
}
