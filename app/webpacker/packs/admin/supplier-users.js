import accessibleAutocomplete from "accessible-autocomplete";

const supplierSelect = document.querySelector("[name='supplier_user_form[supplier]']");

if (supplierSelect !== null) {
  accessibleAutocomplete.enhanceSelectElement({
    selectElement: supplierSelect,
  });
}
