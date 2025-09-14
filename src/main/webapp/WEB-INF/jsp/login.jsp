<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="pt-br">
  <head>
    <title>Login</title>
    <script src="https://cdn.tailwindcss.com"></script>
  </head>
  <body class="bg-gray-50 text-gray-900">
    <div class="max-w-2xl mx-auto p-6">
      <h1 class="text-3xl font-bold mb-4">Faça login</h1>

      <div class="mb-4">
        <% if (request.getParameter("error") != null) { %>
          <div class="bg-red-100 text-red-800 p-3 rounded">Credenciais inválidas. Tente novamente.</div>
        <% } %>
        <% if (request.getParameter("logout") != null) { %>
          <div class="bg-green-100 text-green-800 p-3 rounded">Você saiu com sucesso.</div>
        <% } %>
      </div>

  <form action="<%= request.getContextPath() %>/login" method="post" class="bg-white shadow-md rounded px-8 pt-6 pb-8 mb-4">
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />

        <div class="mb-4">
          <label class="block text-gray-700 text-sm font-bold mb-2" for="email">
            Email
          </label>
          <input name="email" id="email" type="email" required
                 class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
                 placeholder="Digite seu email">
        </div>
        <div class="mb-6">
          <label class="block text-gray-700 text-sm font-bold mb-2" for="password">
            Senha
          </label>
          <input name="password" id="password" type="password" required
                 class="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 mb-3 leading-tight focus:outline-none focus:shadow-outline"
                 placeholder="Digite sua senha">
        </div>
        <div class="flex items-center justify-between">
          <button class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline" type="submit">
            Entrar
          </button>
          <a class="bg-green-500 hover:bg-green-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline" href="/registrar">
            cadastrar
          </a>
        </div>
      </form>
    </div>
  </body>
</html>
