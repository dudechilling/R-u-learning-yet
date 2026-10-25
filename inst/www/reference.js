"use strict";
// The Viewer is static and offline. This script never executes displayed R.
document.addEventListener("click", async function(event) {
  const button = event.target.closest("button.copy");
  if (!button) return;
  const code = document.getElementById(button.dataset.target || "");
  if (!code) return;
  const text = code.textContent;
  const status = button.closest("section").querySelector(".copy-status");
  let copied = false;
  if (navigator.clipboard && window.isSecureContext) {
    try {
      await navigator.clipboard.writeText(text);
      copied = true;
    } catch (error) { copied = false; }
  }
  if (!copied) {
    const buffer = document.createElement("textarea");
    buffer.value = text;
    buffer.readOnly = true;
    buffer.style.position = "fixed";
    buffer.style.top = "0";
    buffer.style.left = "-9999px";
    document.body.appendChild(buffer);
    buffer.focus();
    buffer.select();
    try { copied = document.execCommand("copy") === true; }
    catch (error) { copied = false; }
    buffer.remove();
    button.focus();
  }
  if (copied) {
    button.textContent = "Copied";
    if (status) status.textContent = "R code copied. Paste into your R script.";
  } else {
    const selection = window.getSelection();
    if (selection) {
      const range = document.createRange();
      range.selectNodeContents(code);
      selection.removeAllRanges();
      selection.addRange(range);
    }
    button.textContent = "Copy";
    if (status) status.textContent =
      "Clipboard access unavailable. The code is selected; press Ctrl+C (Command+C on macOS) to copy.";
  }
});
/* W2 local reference focus restoration; no raw learner data is persisted. */
(function () {
  const key = "ru-w2-focus-v1";
  function restore() {
    let id = null;
    try { id = sessionStorage.getItem(key); }
    catch (_) { return; }
    if (!id || !/^[a-z0-9_-]+$/.test(id)) return;
    const target = document.getElementById(id);
    if (target && target.matches(".results a")) {
      try { sessionStorage.removeItem(key); } catch (_) { /* blocked */ }
      target.focus({preventScroll:true});
      target.scrollIntoView({block:"nearest"});
    } else {
      const heading = document.querySelector("#content h1");
      if (heading) { heading.tabIndex = -1; heading.focus({preventScroll:true}); }
    }
  }
  document.addEventListener("DOMContentLoaded", function () {
    document.querySelectorAll(".results a").forEach(function (link, index) {
      if (!link.id) link.id = "ru-choice-" + index;
      link.addEventListener("click", function () {
        if (!/^[a-z0-9_-]+$/.test(link.id)) return;
        try { sessionStorage.setItem(key, link.id); } catch (_) { /* local storage blocked */ }
      });
    });
    restore();
    const back = document.querySelector("button.w2-return-context");
    if (back) back.addEventListener("click", function () {
      if (history.length > 1) history.back();
      else window.location.assign("results.html");
    });
  });
  window.addEventListener("pageshow", function (event) { if (event.persisted) restore(); });
})();
