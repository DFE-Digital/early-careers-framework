const cookieBannerEl = document.querySelector(".js-cookie-banner");

if (cookieBannerEl) {
  const cookieFormEl = document.querySelector(".js-cookie-form");

  cookieFormEl.addEventListener("click", (e) => {
    if (e.target.tagName !== "BUTTON") {
      return;
    }

    const body = new FormData(cookieFormEl);
    body.append("cookies_form[analytics_consent]", e.target.value);

    fetch(cookieFormEl.action, {
      method: "PUT",
      headers: {
        Accept: "application/json",
      },
      body,
    })
      .then((res) => {
        if (res.status >= 200 && res.status < 300) {
          return res;
        }

        throw new Error(res);
      })
      .then((res) => res.json())
      .then(({ message }) => {
        const messageEl = cookieBannerEl.querySelector(".js-cookie-message");
        messageEl.textContent = message;

        cookieBannerEl
          .querySelector(".js-cookie-banner__form")
          .setAttribute("hidden", "");
        cookieBannerEl
          .querySelector(".js-cookie-banner__success")
          .removeAttribute("hidden");
      });

    const gaSrc = window.ecfAnalyticsScript;
    if (e.target.value === "on" && gaSrc) {
      const scriptEl = document.createElement("script");
      scriptEl.src = gaSrc;
      document.body.appendChild(scriptEl);
    }

    e.preventDefault();
  });

  const hideBannerEl = document.querySelector(".js-hide-cookie-banner");
  hideBannerEl.addEventListener("click", (e) => {
    e.preventDefault();

    cookieBannerEl.setAttribute("hidden", "");
  });
}
