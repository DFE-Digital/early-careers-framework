import accessibleAutocomplete from "accessible-autocomplete";

function ecfAccessibleAutocomplete(opts) {
  if (!opts.element) {
    return;
  }

  const source = (query, populateResults) => {
    fetch(`${opts.apiPath}?search_key=${query}`)
      .then((response) => response.json())
      .then((data) => populateResults(data));
  };

  accessibleAutocomplete({
    source,
    showNoOptionsFound: false,
    minLength: 1,
    name: opts.element.dataset.inputName,
    templates: {
      inputValue: (result) => result && result.name,
      suggestion: (result) => `<strong>${result.name}</strong>`,
    },
    ...opts,
  });
}

ecfAccessibleAutocomplete({
  element: document.querySelector("#local-authority-autocomplete"),
  id: "autocomplete-local-authority-name-field",
  apiPath: "/api/local_authority_search",
});

ecfAccessibleAutocomplete({
  element: document.querySelector("#school-autocomplete"),
  id: "autocomplete-school-name-field",
  apiPath: "/api/school_search",
  templates: {
    inputValue: (result) => result && result.name,
    suggestion: (result) =>
      `<strong>${result.name}</strong> (${result.full_address_formatted})`,
  },
});

ecfAccessibleAutocomplete({
  element: document.querySelector("#network-autocomplete"),
  id: "autocomplete-network-name-field",
  apiPath: "/api/network_search",
});

ecfAccessibleAutocomplete({
  element: document.querySelector("#location-autocomplete"),
  id: "autocomplete-location-field",
  source: ["here", "there"],
});
