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
    var cpf = document.getElementById("cpf");
    if (cpf && Utils.cpfMask) {
      cpf.addEventListener("input", function () {
        var raw = Utils.cpfMask.unmask(cpf.value);
        cpf.value = Utils.cpfMask.mask(raw);
      });
      if (cpf.form) {
        cpf.form.addEventListener("submit", function () {
          cpf.value = Utils.cpfMask.unmask(cpf.value);
        });
      }
    }
  }
  if (document.readyState === "loading")
    document.addEventListener("DOMContentLoaded", run);
  else run();
})();
