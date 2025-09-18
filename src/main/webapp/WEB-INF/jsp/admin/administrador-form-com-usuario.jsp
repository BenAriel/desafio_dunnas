<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
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
  <c:if test="${not empty error}">
    <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4" data-auto-dismiss="3000">
      ${error}
    </div>
  </c:if>
  <form:form modelAttribute="form" action="${pageContext.request.contextPath}/admin/administradores/criar" method="post" cssClass="bg-white shadow-md rounded px-8 pt-6 pb-8">
      <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />

      <div class="mb-4">
        <label class="block text-sm font-medium mb-1" for="nome">Nome</label>
        <form:input path="nome" id="nome" cssClass="border rounded w-full p-2" />
        <form:errors path="nome" cssClass="text-red-600 text-sm" />
      </div>

      <div class="mb-4">
        <label class="block text-sm font-medium mb-1" for="email">Email</label>
        <form:input path="email" id="email" type="email" cssClass="border rounded w-full p-2" />
        <form:errors path="email" cssClass="text-red-600 text-sm" />
      </div>

      <div class="mb-4">
        <label class="block text-sm font-medium mb-1" for="senha">Senha</label>
        <form:password path="senha" id="senha" cssClass="border rounded w-full p-2" />
        <form:errors path="senha" cssClass="text-red-600 text-sm" />
      </div>

      <div class="mb-4">
        <label class="block text-sm font-medium mb-1" for="matricula">Matrícula</label>
        <form:input path="matricula" id="matricula" cssClass="border rounded w-full p-2" />
        <form:errors path="matricula" cssClass="text-red-600 text-sm" />
      </div>

      <div class="mb-6">
        <label class="block text-sm font-medium mb-1" for="cpf">CPF</label>
        <form:input path="cpf" id="cpf" cssClass="border rounded w-full p-2" inputmode="numeric" maxlength="14" />
        <form:errors path="cpf" cssClass="text-red-600 text-sm" />
      </div>

      <div class="flex gap-2 justify-between">
        <button type="submit" class="bg-blue-600 text-white rounded px-4 py-2">Salvar</button>
        <a class="text-blue-600" href="<c:url value='/admin'/>">Cancelar</a>
      </div>
  </form:form>
  </div>
  <script defer src="<c:url value='/js/admin/administrador-form-com-usuario.js'/>"></script>
</body>
</html>
