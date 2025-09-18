<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
  <meta charset="UTF-8" />
  <title>Novo Cliente</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <script src="<c:url value='/js/utils.js'/>"></script>
</head>
<body class="bg-gray-50 text-gray-900">
  <div class="max-w-2xl mx-auto p-6">
    <h1 class="text-2xl font-bold mb-4 text-center">Cadastrar Cliente</h1>
  <form:form id="registrarForm" modelAttribute="form" action="${pageContext.request.contextPath}/registrar" method="post" cssClass="bg-white shadow-md rounded px-8 pt-6 pb-8">
      <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />

      <div class="mb-4">
        <label class="block text-sm font-medium mb-1" for="nome">Nome</label>
  <form:input class="border rounded w-full p-2" type="text" id="nome" path="nome" />
  <form:errors path="nome" cssClass="text-red-600 text-sm" />
      </div>

      <div class="mb-4">
        <label class="block text-sm font-medium mb-1" for="email">Email</label>
  <form:input class="border rounded w-full p-2" type="email" id="email" path="email" />
  <form:errors path="email" cssClass="text-red-600 text-sm" />
      </div>

      <div class="mb-4">
        <label class="block text-sm font-medium mb-1" for="senha">Senha</label>
  <form:password class="border rounded w-full p-2" id="senha" path="senha" />
  <form:errors path="senha" cssClass="text-red-600 text-sm" />
      </div>

      <div class="mb-4">
        <label class="block text-sm font-medium mb-1" for="telefone">Telefone</label>
        <form:input class="border rounded w-full p-2" type="text" id="telefone" path="telefone" inputmode="numeric" autocomplete="tel" maxlength="15" />
      </div>

      <div class="mb-6">
        <label class="block text-sm font-medium mb-1" for="profissao">Profissão</label>
  <form:input class="border rounded w-full p-2" type="text" id="profissao" path="profissao" />
      </div>

   <div class="flex items-center justify-between">
        <button type="submit" class="bg-blue-600 text-white rounded px-4 py-2">Salvar</button>
        <a class="text-blue-600" href="<c:url value='/admin'/>">Cancelar</a>
      </div>
  </form:form>
  </div>
  <script defer src="<c:url value='/js/registrar.js'/>"></script>
</body>
</html>
