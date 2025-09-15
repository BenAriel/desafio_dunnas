<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <title>Relatório Financeiro</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-50 text-gray-900">
    <%@ include file="/WEB-INF/jsp/components/header.jsp" %>
    <main class="max-w-6xl mx-auto p-6">
        <h1 class="text-3xl font-bold mb-6">Relatório Financeiro</h1>
        <p class="text-gray-600 mb-4">Relatórios financeiros por período e setor (em construção).</p>

        <div class="mt-8">
            <a href="<c:url value='/admin/relatorios'/>" 
               class="bg-gray-600 hover:bg-gray-700 text-white px-4 py-2 rounded">
                Voltar
            </a>
        </div>
    </main>
</body>
</html>
