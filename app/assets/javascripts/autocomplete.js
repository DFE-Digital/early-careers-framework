/**
 * It enables autocomplete for all select elements with class "autocomplete"
 */

import accessibleAutocomplete from "accessible-autocomplete";

const selects = document.querySelectorAll("select.autocomplete");

selects.forEach((select) => {
  accessibleAutocomplete.enhanceSelectElement({
    selectElement: select,
  });
});
