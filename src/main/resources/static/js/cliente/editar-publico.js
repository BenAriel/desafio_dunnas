(function () {
  "use strict";
  function run() {
    var Utils = window.Utils || {};
    var tel = document.getElementById("telefone");
    if (tel && Utils.telefoneMask) {
      tel.addEventListener("input", function () {
        var raw = Utils.telefoneMask.unmask(tel.value);
        tel.value = Utils.telefoneMask.mask(raw);
      });
      if (tel.form) {
        tel.form.addEventListener("submit", function () {
          tel.value = Utils.telefoneMask.unmask(tel.value);
        });
      }
    }
  }
  if (document.readyState === "loading")
    document.addEventListener("DOMContentLoaded", run);
  else run();
})();
