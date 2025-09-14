<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
  <meta charset="UTF-8" />
  <title>Novo Administrador</title>
  <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-50 text-gray-900">
  <div class="max-w-2xl mx-auto p-6">
    <h1 class="text-2xl font-bold mb-4">Cadastrar Administrador</h1>
    <form action="<c:url value='/admin/administradores/salvar'/>" method="post" class="bg-white shadow-md rounded px-8 pt-6 pb-8">
      <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />

      <div class="mb-4">
        <label class="block text-sm font-medium mb-1" for="usuarioId">ID do Usuário (já existente com ROLE_ADMIN)</label>
        <input class="border rounded w-full p-2" type="number" id="usuarioId" name="usuarioId" required />
      </div>

      <div class="mb-4">
        <label class="block text-sm font-medium mb-1" for="matricula">Matrícula</label>
        <input class="border rounded w-full p-2" type="text" id="matricula" name="matricula" required />
      </div>

      <div class="mb-6">
        <label class="block text-sm font-medium mb-1" for="cpf">CPF (11 dígitos, opcional)</label>
        <input class="border rounded w-full p-2" type="text" id="cpf" name="cpf" maxlength="11" />
      </div>

      <div class="flex gap-2">
        <button type="submit" class="bg-blue-600 text-white rounded px-4 py-2">Salvar</button>
        <a class="text-blue-600" href="<c:url value='/admin'/>">Cancelar</a>
      </div>
    </form>
  </div>
</body>
</html>
