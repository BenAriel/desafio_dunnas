export function createForm({ formId, onSubmit }) {
  const form = document.getElementById(formId);
  if (!form) {
    console.warn(`createForm: formulário #${formId} não encontrado`);
    return {
      register: () => {},
      state: { values: {}, errors: {}, touched: {} },
    };
  }

  const state = { values: {}, errors: {}, touched: {} };
  const validators = {};

  function ensureErrorEl(inputEl) {
    let errEl = inputEl.nextElementSibling;
    if (!errEl || !errEl.classList.contains("form-error")) {
      errEl = document.createElement("div");
      errEl.className = "form-error text-red-600 text-sm mt-1";
      inputEl.parentNode.insertBefore(errEl, inputEl.nextSibling);
    }
    return errEl;
  }

  function runValidate(name) {
    const v = validators[name];
    const val = state.values[name] ?? "";
    let error = "";
    if (typeof v === "function") {
      const res = v(val);
      if (res !== true) error = res || "Campo inválido";
    }
    state.errors[name] = error;
    const el = form.querySelector(`[name="${name}"]`);
    if (el) {
      const errEl = ensureErrorEl(el);
      errEl.textContent = error;
    }
  }

  function register(name, { validate, parse } = {}) {
    const el = form.querySelector(`[name="${name}"]`);
    validators[name] = validate;
    if (!el) return;
    // inicializa valor
    const initial = el.value ?? "";
    state.values[name] = parse ? parse(initial) : initial;

    el.addEventListener("input", (e) => {
      const val = e.target.value ?? "";
      state.values[name] = parse ? parse(val) : val;
      if (state.touched[name]) runValidate(name);
    });
    el.addEventListener("blur", () => {
      state.touched[name] = true;
      runValidate(name);
    });
  }

  function handleSubmit(ev) {
    ev.preventDefault();
    Object.keys(validators).forEach(runValidate);
    const hasError = Object.values(state.errors).some(Boolean);
    if (!hasError && typeof onSubmit === "function") {
      onSubmit({ values: state.values, form });
    }
  }

  form.addEventListener("submit", handleSubmit);
  return { register, state };
}
