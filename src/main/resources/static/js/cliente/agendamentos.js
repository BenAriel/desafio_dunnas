(function () {
  "use strict";

  function parse(raw) {
    if (!raw) return null;
    var s = String(raw).trim().replace(" ", "T");
    var d = new Date(s);
    if (!isNaN(d.getTime())) return d;
    try {
      var parts = s.split(/[T ]/);
      if (parts.length === 2) {
        var date = parts[0].split("-").map(Number);
        var time = parts[1].split(":").map(Number);
        var Y = date[0],
          M = (date[1] || 1) - 1,
          D = date[2] || 1;
        var h = time[0] || 0,
          m = time[1] || 0,
          sec = time[2] || 0;
        d = new Date(Y, M, D, h, m, sec, 0);
        if (!isNaN(d.getTime())) return d;
      }
    } catch (_) {}
    return null;
  }

  function run() {
    try {
      var serverNow = null;
      var meta = document.querySelector('meta[name="server-now"]');
      if (meta && meta.content) {
        var sn = parse(meta.content);
        if (sn) serverNow = sn;
      }
      var agora = serverNow || new Date();

      document.querySelectorAll(".cancel-confirmado").forEach(function (el) {
        var raw = el.getAttribute("data-inicio");
        if (!raw) return;
        var d = parse(raw);

        if (d) {
          var limite = new Date(d.getTime());
          if (agora >= limite) el.style.display = "none";
        }
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
