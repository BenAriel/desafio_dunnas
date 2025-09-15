<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
  <meta charset="UTF-8" />
  <title>Ocorreu um erro</title>
  <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-50 text-gray-900">
  <main class="max-w-2xl mx-auto p-6">
    <div class="bg-white shadow rounded p-6">
      <h1 class="text-2xl font-bold mb-2">Ops! Ocorreu um erro</h1>
      <p class="text-gray-700 mb-4">Tente novamente mais tarde. Se o problema persistir, contate o suporte.</p>

      <div class="text-sm text-gray-600 space-y-1">
        <p><span class="font-semibold">Status:</span> <c:out value="${status}" /></p>
        <p><span class="font-semibold">Erro:</span> <c:out value="${error}" /></p>
        <c:if test="${not empty message}">
          <p><span class="font-semibold">Mensagem:</span> <c:out value="${message}" /></p>
        </c:if>
        <c:if test="${not empty path}">
          <p><span class="font-semibold">Caminho:</span> <c:out value="${path}" /></p>
        </c:if>
        <c:if test="${not empty timestamp}">
          <p><span class="font-semibold">Quando:</span> <c:out value="${timestamp}" /></p>
        </c:if>
      </div>

      <div class="mt-6">
        <a href="<c:url value='/'/>" class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded">Voltar ao início</a>
      </div>
    </div>
  </main>
</body>
</html>
