export const cpfMask = {
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

export const telefoneMask = {
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
