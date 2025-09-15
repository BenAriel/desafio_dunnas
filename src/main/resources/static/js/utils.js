// Utilidades globais para uso direto no navegador (sem ES Modules)
// Disponíveis em window.Utils
(function (global) {
  "use strict";

  // === Implementações originais das máscaras ===
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

  const Utils = { cpfMask, telefoneMask, roles, roleLabels };
  // Mescla com Utils existente, se houver
  global.Utils = Object.assign({}, global.Utils || {}, Utils);
})(window);
