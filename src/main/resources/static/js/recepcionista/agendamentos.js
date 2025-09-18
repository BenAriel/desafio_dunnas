// Lógicas da página recepcionista/agendamentos.jsp
(function () {
  "use strict";

  function parseIsoToLocal(raw) {
    if (!raw) return null;
    if (window.Utils && typeof window.Utils.parseIsoToLocal === "function") {
      return window.Utils.parseIsoToLocal(raw);
    }
    var d = new Date(raw);
    if (isNaN(d.getTime())) d = new Date(String(raw).replace(" ", "T"));
    return isNaN(d.getTime()) ? null : d;
  }

  function formatBR(d) {
    try {
      return d.toLocaleString("pt-BR", {
        year: "numeric",
        month: "2-digit",
        day: "2-digit",
        hour: "2-digit",
        minute: "2-digit",
      });
    } catch (_) {
      return d.toString();
    }
  }

  function run() {
    try {
      var agora = new Date();
      document.querySelectorAll(".cancel-confirmado").forEach(function (el) {
        var v = el.getAttribute("data-inicio");
        if (!v) return;
        var inicio = parseIsoToLocal(v);
        if (inicio && inicio <= agora) {
          el.style.display = "none";
        }
      });

      document.querySelectorAll(".btn-confirmar").forEach(function (btn) {
        var raw = btn.getAttribute("data-inicio");
        if (!raw) return;
        var d = parseIsoToLocal(raw);
        if (d && d <= agora) {
          btn.style.display = "none";
        }
      });

      document.querySelectorAll(".btn-finalizar").forEach(function (btn) {
        var raw = btn.getAttribute("data-inicio");
        if (!raw) return;
        var d = parseIsoToLocal(raw);
        if (d && d > agora) {
          btn.style.display = "none";
        }
      });

      document.querySelectorAll("[data-datetime]").forEach(function (span) {
        var raw = span.getAttribute("data-datetime");
        var d = parseIsoToLocal(raw);
        if (d) span.textContent = formatBR(d);
      });

      document.querySelectorAll("[data-auto-dismiss]").forEach(function (el) {
        var ms = parseInt(el.getAttribute("data-auto-dismiss")) || 3000;
        setTimeout(function () {
          el.style.display = "none";
        }, ms);
      });

      // Confirmação ao finalizar antes do fim
      document.querySelectorAll(".btn-finalizar").forEach(function (btn) {
        btn.addEventListener(
          "click",
          function (e) {
            try {
              var rawFim = btn.getAttribute("data-fim");
              if (!rawFim) return;
              var fim = parseIsoToLocal(rawFim);
              var agoraLocal = new Date();
              if (fim && agoraLocal < fim) {
                e.preventDefault();
                var form = btn.closest("form");
                var msg =
                  "O horário de término ainda não chegou. Deseja finalizar mesmo assim?";
                if (
                  window.Utils &&
                  typeof window.Utils.openConfirmModal === "function"
                ) {
                  window.Utils.openConfirmModal(msg, function (ok) {
                    if (ok && form) form.submit();
                  });
                } else if (confirm(msg)) {
                  if (form) form.submit();
                }
              }
            } catch (_) {}
          },
          true
        );
      });
    } catch (_) {}
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", run);
  } else {
    run();
  }
})();
