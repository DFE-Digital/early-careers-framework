const editSchoolFormEl = document.querySelector(".js-partnerships-form");

function getCheckedSchools() {
  const checkedSchools = sessionStorage.getItem("school-search-checked");
  if (checkedSchools) {
    try {
      return new Set(JSON.parse(checkedSchools));
    } catch (err) {
      // @todo is there a way of monitoring this?
      // eslint-disable-next-line no-console
      console.warn("Error getting saved data", err);
      return new Set();
    }
  }

  return new Set();
}

function setCheckedSchools(checkedSchools) {
  const checkedSchoolsString = JSON.stringify(Array.from(checkedSchools));
  sessionStorage.setItem("school-search-checked", checkedSchoolsString);
}

const getSubmitButton = () =>
  editSchoolFormEl.querySelector(".js-partnerships-submit");
const getClearButton = () =>
  editSchoolFormEl.querySelector(".js-partnerships-clear");
const getSelectAll = () =>
  editSchoolFormEl.querySelector(
    "input[name='partnership_form[select_all]'][type='checkbox']"
  );
const getCheckboxes = () =>
  Array.from(
    editSchoolFormEl.querySelectorAll(
      "input[name='partnership_form[schools][]'][type='checkbox']"
    )
  );

function updateButtons(checkedSchools) {
  const submitButton = getSubmitButton();
  const clearButton = getClearButton();

  if (checkedSchools.size === 0) {
    submitButton.disabled = true;
    submitButton.value = "Add partnerships";
    clearButton.classList.add("govuk-!-display-none");
  } else {
    const schoolCount = `${checkedSchools.size} school${
      checkedSchools.size === 1 ? "" : "s"
    }`;

    submitButton.disabled = false;
    submitButton.value = `Add partnerships with ${schoolCount}`;
    clearButton.classList.remove("govuk-!-display-none");
    clearButton.innerText = `Remove all ${schoolCount}`;
  }
}

function updateSelectAll() {
  const selectAll = getSelectAll();
  const allChecked = getCheckboxes().every((checkbox) => checkbox.checked);
  selectAll.checked = !!allChecked;
}

function updateButtonsAndSelectAll(checkedSchools) {
  updateButtons(checkedSchools);
  updateSelectAll();
}

const storeCheckboxState = (target) => {
  const checkedSchools = getCheckedSchools();

  if (target.checked) {
    checkedSchools.add(target.value);
  } else {
    checkedSchools.delete(target.value);
  }
  setCheckedSchools(checkedSchools);
  return checkedSchools;
};

const onCheckboxClicked = ({ target }) => {
  if (target.name !== "partnership_form[schools][]") {
    return;
  }
  const checkedSchools = storeCheckboxState(target);
  updateButtonsAndSelectAll(checkedSchools);
};

const onSelectAllClicked = ({ target }) => {
  getCheckboxes().forEach((checkbox) => {
    checkbox.checked = target.checked;
    storeCheckboxState(checkbox);
  });
  updateButtons(getCheckedSchools());
};

function clearCheckedSchools() {
  const checkedSchools = getCheckedSchools();
  checkedSchools.forEach((id) => {
    const checkboxEl = editSchoolFormEl.querySelector(`[value="${id}"]`);
    if (checkboxEl?.type === "hidden") {
      checkboxEl.parentElement.removeChild(checkboxEl);
    } else if (checkboxEl) {
      checkboxEl.checked = false;
    }
  });

  setCheckedSchools(new Set());
  updateButtonsAndSelectAll(new Set());
}

try {
  if (editSchoolFormEl) {
    const initialData = getCheckedSchools();

    initialData.forEach((id) => {
      const checkboxEl = document.querySelector(`[value="${id}"]`);

      if (checkboxEl) {
        checkboxEl.checked = true;
      } else {
        const hiddenInputEl = document.createElement("input");

        hiddenInputEl.type = "hidden";
        hiddenInputEl.value = id;
        hiddenInputEl.name = "partnership_form[schools][]";

        editSchoolFormEl.appendChild(hiddenInputEl);
      }
    });

    updateButtonsAndSelectAll(initialData);

    editSchoolFormEl.addEventListener("click", onCheckboxClicked);
    getSelectAll().addEventListener("click", onSelectAllClicked);

    getClearButton()?.addEventListener("click", (event) => {
      event.preventDefault();
      clearCheckedSchools();
    });
  }
} catch (e) {
  // @TODO: monitoring
  // eslint-disable-next-line no-console
  console.error(e);
}
