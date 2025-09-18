// Máscara de CPF no formulário de administrador
(function () {
  "use strict";
  function run() {
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
