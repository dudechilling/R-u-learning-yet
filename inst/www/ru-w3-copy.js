/* Offline W3 clipboard helper: copies the displayed preview only; never runs R. */
(function () {
  "use strict";

  function attach() {
    var button = document.getElementById("w3-copy-code");
    var source = document.getElementById("w3-r-code");
    var status = document.getElementById("w3-copy-status");
    if (!button || !source || !status) return;

    function succeeded() {
      status.textContent = "R code copied. Paste it into an RStudio script or Console to run it yourself.";
    }
    function fallback() {
      var selection = null;
      try {
        selection = window.getSelection();
        var range = document.createRange();
        range.selectNodeContents(source);
        selection.removeAllRanges();
        selection.addRange(range);
        var copied = document.execCommand("copy");
        if (copied) succeeded();
        else status.textContent = "Automatic copying is unavailable. Select the R code and copy it manually.";
      } catch (unused) {
        status.textContent = "Automatic copying is unavailable. Select the R code and copy it manually.";
      } finally {
        if (selection) selection.removeAllRanges();
      }
    }

    button.addEventListener("click", function () {
      var sourceText = source.textContent || "";
      if (!sourceText.trim()) {
        status.textContent = "There is no R code to copy.";
        return;
      }
      if (navigator.clipboard && typeof navigator.clipboard.writeText === "function") {
        navigator.clipboard.writeText(sourceText).then(succeeded, fallback);
      } else {
        fallback();
      }
    });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", attach);
  } else {
    attach();
  }
}());