(function () {
  "use strict";

  function toNumberBR(v) {
    if (v == null) return 0;
    var s = String(v).trim();
    if (!s) return 0;
    if (s.indexOf(",") >= 0) {
      s = s.replace(/\./g, "").replace(",", ".");
      var n1 = Number(s);
      return isNaN(n1) ? 0 : n1;
    }
    var n = Number(s);
    return isNaN(n) ? 0 : n;
  }

  function getValorPorHora() {
    var cont = document.getElementById("resumoPreco");
    if (!cont) return 0;
    return toNumberBR(cont.getAttribute("data-valor-por-hora"));
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

  function bind() {
    var ini = document.getElementById("dataHoraInicio");
    var fim = document.getElementById("dataHoraFim");
    if (ini) {
      ini.addEventListener("change", recalc);
      ini.addEventListener("input", recalc);
    }
    if (fim) {
      fim.addEventListener("change", recalc);
      fim.addEventListener("input", recalc);
    }
    recalc();
  }

  if (document.readyState === "loading")
    document.addEventListener("DOMContentLoaded", bind);
  else bind();
})();
