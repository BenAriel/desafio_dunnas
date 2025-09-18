<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="pt-br">
  <head>
    <title>Login</title>
    <script src="https://cdn.tailwindcss.com"></script>
  </head>
  <body class="bg-gray-50 text-gray-900">
    <div class="max-w-2xl mx-auto p-6">
      <h1 class="text-3xl font-bold mb-4 text-center"> login</h1>

      <div class="mb-4 space-y-2">
        <c:if test="${not empty param.error}">
          <div class="bg-red-100 text-red-800 p-3 rounded" data-auto-dismiss="3000">Credenciais inválidas. Tente novamente.</div>
        </c:if>
        <c:if test="${not empty param.logout}">
          <div class="bg-green-100 text-green-800 p-3 rounded" data-auto-dismiss="3000">Você saiu com sucesso.</div>
        </c:if>
        <c:if test="${not empty error}">
          <div class="bg-red-100 text-red-800 p-3 rounded" data-auto-dismiss="8000">${error}</div>
        </c:if>
        <c:if test="${not empty success}">
          <div class="bg-green-100 text-green-800 p-3 rounded" data-auto-dismiss="8000">${success}</div>
        </c:if>
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
        <div class="mt-4 flex justify-between text-sm">
          <a class="text-blue-600 hover:underline" href="<c:url value='/cliente/editar'/>">Esqueci minha senha / atualizar cadastro</a>
          <span></span>
        </div>
      </form>
      <div class="mt-12 flex justify-center">
        <img src="<c:url value='/images/logo.png'/>" alt="Logo" class="h-56 opacity-80" />
      </div>
    </div>
  </body>
</html>
