// Utilidades globais para uso direto no navegador (sem ES Modules)
// Disponíveis em window.Utils
(function (global) {
  "use strict";

  const cpfMask = {
    mask(texto) {
      return (
        texto
          ?.replace(/\D/g, "")
          .replace(/(\d{3})(\d)/, "$1.$2")
          .replace(/(\d{3})(\d)/, "$1.$2")
          .replace(/(\d{3})(\d{1,2})/, "$1-$2")
          .replace(/(-\d{2})\d+?$/, "$1") ?? ""
      );
    },
    unmask(texto) {
      return texto?.replace(/\D/g, "").slice(0, 11) ?? "";
    },
  };

  const telefoneMask = {
    mask(texto) {
      return (
        texto
          ?.replace(/\D/g, "")
          .replace(/(\d{2})(\d)/, "($1) $2")
          .replace(/(\d{5})(\d)/, "$1-$2")
          .replace(/(-\d{4})\d+?$/, "$1") ?? ""
      );
    },
    unmask(texto) {
      return texto?.replace(/\D/g, "").slice(0, 11) ?? "";
    },
  };

  const roles = {
    ROLE_ADMIN: "ROLE_ADMIN",
    ROLE_RECEPCIONISTA: "ROLE_RECEPCIONISTA",
    ROLE_CLIENTE: "ROLE_CLIENTE",
  };

  const roleLabels = {
    [roles.ROLE_ADMIN]: "Administrador",
    [roles.ROLE_RECEPCIONISTA]: "Recepcionista",
    [roles.ROLE_CLIENTE]: "Cliente",
  };

  function formatDateBR(date) {
    const pad = (x) => String(x).padStart(2, "0");
    return `${pad(date.getDate())}/${pad(
      date.getMonth() + 1
    )}/${date.getFullYear()}`;
  }

  function formatDateTimeBR(date) {
    const pad = (x) => String(x).padStart(2, "0");
    return `${pad(date.getDate())}/${pad(
      date.getMonth() + 1
    )}/${date.getFullYear()} ${pad(date.getHours())}:${pad(date.getMinutes())}`;
  }

  function parseIsoToLocal(s) {
    if (!s) return null;
    const str = String(s).trim();
    // Captura YYYY-MM-DD[ T]HH:mm[:ss] ignorando frações/timezone
    const m = str.match(
      /^(\d{4}-\d{2}-\d{2})(?:[ T](\d{2}):(\d{2})(?::(\d{2}))?)?/
    );
    if (m) {
      const [y, mo, d] = m[1].split("-").map(Number);
      const h = m[2] != null ? Number(m[2]) : 0;
      const mi = m[3] != null ? Number(m[3]) : 0;
      const ss = m[4] != null ? Number(m[4]) : 0;
      return new Date(y, mo - 1, d, h, mi, ss);
    }
    const parsed = Date.parse(str);
    return isNaN(parsed) ? null : new Date(parsed);
  }

  function formatDateNodes(root = document) {
    const nodes = root.querySelectorAll("[data-datetime]");
    nodes.forEach((n) => {
      try {
        const raw = n.getAttribute("data-datetime");
        const dt = parseIsoToLocal(raw);
        if (!dt) return;
        n.textContent = formatDateTimeBR(dt);
      } catch (_) {}
    });
  }

  function initAutoDismiss(root = document) {
    const nodes = root.querySelectorAll("[data-auto-dismiss]");
    nodes.forEach((n) => {
      const t = parseInt(n.getAttribute("data-auto-dismiss"), 10);
      if (!isNaN(t) && t > 0) {
        setTimeout(() => {
          try {
            n.style.transition = "opacity 200ms ease";
            n.style.opacity = "0";
            setTimeout(() => n.remove(), 220);
          } catch (_) {}
        }, t);
      }
    });
  }

  // Modal de confirmação global
  function findConfirmModal(root = document) {
    return root.getElementById("confirm-modal");
  }

  function openConfirmModal(message, onConfirm) {
    var modal = findConfirmModal(document);
    if (!modal) {
      if (typeof onConfirm === "function") onConfirm(false);
      return;
    }
    try {
      var msgNode = modal.querySelector("#confirm-modal-message");
      if (msgNode)
        msgNode.textContent = message || "Tem certeza que deseja prosseguir?";
      var confirmBtn = modal.querySelector("#confirm-modal-confirm");
      var cancelBtn = modal.querySelector("#confirm-modal-cancel");

      confirmBtn.onclick = null;
      cancelBtn.onclick = null;

      var close = function () {
        if (typeof modal.close === "function") {
          try {
            modal.close();
          } catch (_) {}
        } else {
          modal.setAttribute("data-state", "closed");
          modal.style.display = "none";
        }
      };

      confirmBtn.onclick = function () {
        try {
          if (typeof onConfirm === "function") onConfirm(true);
        } finally {
          close();
        }
      };
      cancelBtn.onclick = function () {
        try {
          if (typeof onConfirm === "function") onConfirm(false);
        } finally {
          close();
        }
      };

      // Abre modal
      if (typeof modal.showModal === "function") {
        modal.showModal();
      } else {
        modal.removeAttribute("data-state");
        modal.style.display = "block";
      }
    } catch (_) {
      if (typeof onConfirm === "function") onConfirm(false);
    }
  }

  function wireGlobalConfirmations(root = document) {
    root.addEventListener(
      "click",
      function (ev) {
        var t = ev.target;
        while (t && t !== root) {
          if (
            t.matches &&
            (t.matches("[data-confirm]") || t.matches("[data-confirm-message]"))
          ) {
            var msg =
              t.getAttribute("data-confirm") ||
              t.getAttribute("data-confirm-message") ||
              "Tem certeza?";
            var form = t.closest && t.closest("form");
            if (form) {
              ev.preventDefault();
              openConfirmModal(msg, function (ok) {
                if (ok) {
                  try {
                    form.submit();
                  } catch (_) {}
                }
              });
            } else if (t.tagName === "A" && t.href) {
              ev.preventDefault();
              openConfirmModal(msg, function (ok) {
                if (ok) {
                  window.location.href = t.href;
                }
              });
            } else {
              ev.preventDefault();
              openConfirmModal(msg, function (ok) {
                if (ok) {
                  try {
                    t.click();
                  } catch (_) {}
                }
              });
            }
            return;
          }
          t = t.parentElement;
        }
      },
      true
    );

    root.addEventListener(
      "submit",
      function (ev) {
        var form = ev.target;
        try {
          if (form && form.matches && form.matches("form[data-confirm]")) {
            var msg = form.getAttribute("data-confirm") || "Tem certeza?";
            ev.preventDefault();
            openConfirmModal(msg, function (ok) {
              if (ok) {
                try {
                  form.submit();
                } catch (_) {}
              }
            });
          }
        } catch (_) {}
      },
      true
    );
  }

  const Utils = {
    cpfMask,
    telefoneMask,
    roles,
    roleLabels,
    formatDateBR,
    formatDateTimeBR,
    parseIsoToLocal,
    formatDateNodes,
    initAutoDismiss,
    openConfirmModal,
    wireGlobalConfirmations,
  };

  global.Utils = Object.assign({}, global.Utils || {}, Utils);

  document.addEventListener("DOMContentLoaded", function () {
    try {
      formatDateNodes();
    } catch (_) {}
    try {
      initAutoDismiss();
    } catch (_) {}
    try {
      wireGlobalConfirmations();
    } catch (_) {}
  });
})(window);
