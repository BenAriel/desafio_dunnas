// Máscara de CPF e auto-dismiss no formulário de edição de recepcionista
(function () {
  "use strict";
  function run() {
    document.querySelectorAll("[data-auto-dismiss]").forEach(function (el) {
      var ms = parseInt(el.getAttribute("data-auto-dismiss")) || 3000;
      setTimeout(function () {
        el.style.display = "none";
      }, ms);
    });
    var Utils = window.Utils || {};
    var el = document.getElementById("cpf");
    if (el && Utils.cpfMask) {
      el.addEventListener("input", function () {
        var raw = Utils.cpfMask.unmask(el.value);
        el.value = Utils.cpfMask.mask(raw);
      });
      if (el.form) {
        el.form.addEventListener("submit", function () {
          el.value = Utils.cpfMask.unmask(el.value);
        });
      }
    }
  }
  if (document.readyState === "loading")
    document.addEventListener("DOMContentLoaded", run);
  else run();
})();
