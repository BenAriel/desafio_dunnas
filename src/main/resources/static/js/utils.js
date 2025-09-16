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
  };

  global.Utils = Object.assign({}, global.Utils || {}, Utils);

  document.addEventListener("DOMContentLoaded", function () {
    try {
      formatDateNodes();
    } catch (_) {}
    try {
      initAutoDismiss();
    } catch (_) {}
  });
})(window);
