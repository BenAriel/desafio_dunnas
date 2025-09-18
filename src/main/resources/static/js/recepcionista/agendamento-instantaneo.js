(function () {
  "use strict";

  function toNumberBR(v) {
    if (v == null) return 0;
    var s = String(v).trim();
    if (!s) return 0;
    // Se possuir vírgula, considere vírgula como decimal e pontos como milhar
    if (s.indexOf(",") >= 0) {
      s = s.replace(/\./g, "").replace(",", ".");
      var n1 = Number(s);
      return isNaN(n1) ? 0 : n1;
    }
    // Caso contrário, trate ponto como decimal diretamente
    var n = Number(s);
    return isNaN(n) ? 0 : n;
  }

  function getValorPorHora() {
    var cont = document.getElementById("resumoPreco");
    if (!cont) return 0;
    var raw = cont.getAttribute("data-valor-por-hora");
    return toNumberBR(raw);
  }

  function recalc() {
    var ini = document.getElementById("dataHoraInicio");
    var fim = document.getElementById("dataHoraFim");
    var resumo = document.getElementById("estimativaResumo");
    var sinalEl = document.getElementById("estimativaSinal");
    var restanteEl = document.getElementById("estimativaRestante");

    if (!resumo || !sinalEl || !restanteEl) return;

    var currency = new Intl.NumberFormat("pt-BR", {
      style: "currency",
      currency: "BRL",
    });

    var i = ini && ini.value ? new Date(ini.value) : null;
    var f = fim && fim.value ? new Date(fim.value) : null;
    var vph = getValorPorHora();

    if (!i || !f || isNaN(i.getTime()) || isNaN(f.getTime())) {
      resumo.textContent = "Selecione início e fim";
      sinalEl.textContent = "—";
      restanteEl.textContent = "—";
      return;
    }
    if (f <= i) {
      resumo.textContent = "Fim deve ser após o início";
      sinalEl.textContent = "—";
      restanteEl.textContent = "—";
      return;
    }

    var minutos = Math.round((f - i) / 60000);
    var total = (vph * minutos) / 60.0;
    var sinal = total / 2.0;
    var restante = total - sinal;

    resumo.textContent = minutos + " minutos • " + currency.format(total);
    sinalEl.textContent = currency.format(sinal);
    restanteEl.textContent = currency.format(restante);
  }

  function onSalaChange() {
    var salaSelect = document.getElementById("salaId");
    if (!salaSelect) return;
    salaSelect.addEventListener("change", function () {
      var val = salaSelect.value;
      var setorInput = document.querySelector("input[name='setorId']");
      var setorId = setorInput ? setorInput.value : "";
      if (val) {
        try {
          var url = new URL(window.location.href);
          url.searchParams.set("salaId", val);
          if (setorId) url.searchParams.set("setorId", setorId);
          window.location.href = url.toString();
        } catch (_) {
          // Fallback simples
          var qs =
            "?salaId=" +
            encodeURIComponent(val) +
            (setorId ? "&setorId=" + encodeURIComponent(setorId) : "");
          window.location.search = qs;
        }
      }
    });
  }

  document.addEventListener("DOMContentLoaded", function () {
    try {
      var ini = document.getElementById("dataHoraInicio");
      var fim = document.getElementById("dataHoraFim");
      if (ini) ini.addEventListener("change", recalc);
      if (fim) fim.addEventListener("change", recalc);
      recalc();
    } catch (_) {}

    try {
      onSalaChange();
    } catch (_) {}
  });
})();
