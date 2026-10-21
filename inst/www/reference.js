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
      "Clipboard access unavailable. The code is selected; press Ctrl+C to copy.";
  }
});