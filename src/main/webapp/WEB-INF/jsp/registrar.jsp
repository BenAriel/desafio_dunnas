<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
  <meta charset="UTF-8" />
  <title>Novo Usuário + Cliente</title>
  <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-50 text-gray-900">
  <div class="max-w-2xl mx-auto p-6">
    <h1 class="text-2xl font-bold mb-4">Cadastrar Usuário</h1>
  <form id="registrarForm" action="<c:url value='/registrar'/>" method="post" class="bg-white shadow-md rounded px-8 pt-6 pb-8">
      <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />

      <div class="mb-4">
        <label class="block text-sm font-medium mb-1" for="nome">Nome</label>
        <input class="border rounded w-full p-2" type="text" id="nome" name="nome" required />
      </div>

      <div class="mb-4">
        <label class="block text-sm font-medium mb-1" for="email">Email</label>
        <input class="border rounded w-full p-2" type="email" id="email" name="email" required />
      </div>

      <div class="mb-4">
        <label class="block text-sm font-medium mb-1" for="senha">Senha</label>
        <input class="border rounded w-full p-2" type="password" id="senha" name="senha" required />
      </div>

      <div class="mb-4">
        <label class="block text-sm font-medium mb-1" for="telefone">Telefone</label>
        <input class="border rounded w-full p-2" type="text" id="telefone" name="telefone" inputmode="numeric" autocomplete="tel" maxlength="15" />
      </div>

      <div class="mb-6">
        <label class="block text-sm font-medium mb-1" for="profissao">Profissão</label>
        <input class="border rounded w-full p-2" type="text" id="profissao" name="profissao" />
      </div>

   <div class="flex items-center justify-between">
        <button type="submit" class="bg-blue-600 text-white rounded px-4 py-2">Salvar</button>
        <a class="text-blue-600" href="<c:url value='/admin'/>">Cancelar</a>
      </div>
    </form>
    
    <script type="module">
      import { telefoneMask } from '/js/utils.js';

       import { createForm } from '/js/forms.js';

      const tel = document.getElementById('telefone');
      tel?.addEventListener('input', () => {
        tel.value = telefoneMask.mask(tel.value);
      });
      if (tel && tel.value) tel.value = telefoneMask.mask(tel.value);

      const formCtl = createForm({
        formId: 'registrarForm',
        onSubmit: ({ values, form }) => {
          const telVal = telefoneMask.unmask(values.telefone || '');
          const telInput = form.querySelector('#telefone');
          if (telInput) telInput.value = telVal;
          form.submit();
        }
      });

      formCtl.register('nome', {
        validate: v => v && v.trim().length >= 2 || 'Informe pelo menos 2 caracteres'
      });
      formCtl.register('email', {
        validate: v => /.+@.+\..+/.test(v) || 'Email inválido'
      });
      formCtl.register('senha', {
        validate: v => (v && v.length >= 6) || 'Mínimo 6 caracteres'
      });
      formCtl.register('telefone', {
        parse: v => telefoneMask.unmask(v),
        validate: v => (v === '' || v.length === 11) || 'Telefone deve ter 11 dígitos'
      });
      formCtl.register('profissao');
    </script>
  </div>
</body>
</html>
