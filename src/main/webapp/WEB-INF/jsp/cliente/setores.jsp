<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <title>Setores Disponíveis</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-50 text-gray-900">
    <%@ include file="/WEB-INF/jsp/components/header.jsp" %>
    
    <main class="max-w-6xl mx-auto p-6">
        <h1 class="text-3xl font-bold mb-6">Setores Disponíveis</h1>

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            <c:forEach var="setor" items="${setores}">
                <div class="bg-white shadow rounded-lg p-6 hover:shadow-md transition-shadow">
                    <div class="flex items-center justify-between mb-4">
                        <h3 class="text-xl font-semibold text-gray-900">${setor.nome}</h3>
                        <span class="px-2 py-1 text-xs font-semibold rounded-full ${setor.aberto ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'}">
                            ${setor.aberto ? 'Aberto' : 'Fechado'}
                        </span>
                    </div>
                    
                    <div class="space-y-2 mb-4">
                        <p class="text-sm text-gray-600">
                            <span class="font-medium">Status:</span> ${setor.aberto ? 'Aceitando agendamentos' : 'Fechado para agendamentos'}
                        </p>
                    </div>
                    
                    <div class="flex gap-2">
                        <a href="<c:url value='/cliente/salas?setorId=${setor.id}'/>" 
                           class="flex-1 bg-blue-600 hover:bg-blue-700 text-white text-center px-4 py-2 rounded text-sm">
                            Ver Salas
                        </a>
                    </div>
                </div>
            </c:forEach>
        </div>

        <div class="mt-8">
            <a href="<c:url value='/cliente'/>" 
               class="bg-gray-600 hover:bg-gray-700 text-white px-4 py-2 rounded">
                Voltar
            </a>
        </div>
    </main>
</body>
</html>
