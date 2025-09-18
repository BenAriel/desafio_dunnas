// Lógicas da página cliente/agendamentos.jsp
(function () {
  "use strict";

  function parse(raw) {
    var d = new Date(raw);
    if (isNaN(d.getTime())) d = new Date(String(raw).replace(" ", "T"));
    return isNaN(d.getTime()) ? null : d;
  }

  function run() {
    try {
      var agora = new Date();
      document.querySelectorAll(".cancel-confirmado").forEach(function (el) {
        var raw = el.getAttribute("data-inicio");
        if (!raw) return;
        var d = parse(raw);
        if (d && d <= agora) el.style.display = "none";
      });

      document.querySelectorAll("[data-datetime]").forEach(function (span) {
        var d = parse(span.getAttribute("data-datetime"));
        if (d)
          span.textContent = d.toLocaleString("pt-BR", {
            year: "numeric",
            month: "2-digit",
            day: "2-digit",
            hour: "2-digit",
            minute: "2-digit",
          });
      });

      document.querySelectorAll("[data-auto-dismiss]").forEach(function (el) {
        var ms = parseInt(el.getAttribute("data-auto-dismiss")) || 3000;
        setTimeout(function () {
          el.style.display = "none";
        }, ms);
      });
    } catch (_) {}
  }

  if (document.readyState === "loading")
    document.addEventListener("DOMContentLoaded", run);
  else run();
})();
