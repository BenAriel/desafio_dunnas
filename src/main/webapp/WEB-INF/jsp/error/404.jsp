<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
  <meta charset="UTF-8" />
  <title>Página não encontrada</title>
  <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-50 text-gray-900">
  <main class="max-w-2xl mx-auto p-6">
    <div class="bg-white shadow rounded p-6">
      <h1 class="text-2xl font-bold mb-2">404 - Página não encontrada</h1>
      <p class="text-gray-700 mb-4">A página solicitada não existe ou foi movida.</p>

      <div class="mt-6">
        <a href="<c:url value='/'/>" class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded">Voltar ao início</a>
      </div>
    </div>
  </main>
</body>
</html>
