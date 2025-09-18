<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
  <meta charset="UTF-8" />
  <title>Atualizar Cliente</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <script src="<c:url value='/js/utils.js'/>"></script>
  <script defer src="<c:url value='/js/cliente/editar-publico.js'/>"></script>
  </head>
  <body class="bg-gray-50 text-gray-900">
    <div class="max-w-2xl mx-auto p-6">
      <h1 class="text-2xl font-bold mb-4 text-center">Atualizar Cliente</h1>

      <div class="mb-4 space-y-2">
        <c:if test="${not empty error}">
          <div class="bg-red-100 text-red-800 p-3 rounded" data-auto-dismiss="6000">${error}</div>
        </c:if>
        <c:if test="${not empty success}">
          <div class="bg-green-100 text-green-800 p-3 rounded" data-auto-dismiss="6000">${success}</div>
        </c:if>
      </div>

      <form:form modelAttribute="form" action="${pageContext.request.contextPath}/cliente/editar" method="post" cssClass="bg-white shadow-md rounded px-8 pt-6 pb-8">
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
          <label class="block text-sm font-medium mb-1" for="telefone">Telefone</label>
          <form:input class="border rounded w-full p-2" type="text" id="telefone" path="telefone" inputmode="numeric" autocomplete="tel" maxlength="15" />
          <form:errors path="telefone" cssClass="text-red-600 text-sm" />
        </div>

        <div class="mb-4">
          <label class="block text-sm font-medium mb-1" for="profissao">Profissão (opcional)</label>
          <form:input class="border rounded w-full p-2" type="text" id="profissao" path="profissao" />
        </div>

        <div class="mb-6">
          <label class="block text-sm font-medium mb-1" for="novaSenha">Nova Senha</label>
          <form:password class="border rounded w-full p-2" id="novaSenha" path="novaSenha" />
          <form:errors path="novaSenha" cssClass="text-red-600 text-sm" />
        </div>

        <div class="flex items-center justify-between">
          <button type="submit" class="bg-blue-600 hover:bg-blue-700 text-white font-semibold px-4 py-2 rounded">Salvar</button>
          <a class="text-blue-600 hover:underline" href="<c:url value='/login'/>">Voltar para o login</a>
        </div>
      </form:form>

      <div class="mt-12 flex justify-center">
        <img src="<c:url value='/images/logo.png'/>" alt="Logo" class="h-56 opacity-80" />
      </div>
    </div>

    
  </body>
 </html>
