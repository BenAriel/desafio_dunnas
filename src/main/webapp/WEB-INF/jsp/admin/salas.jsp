<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <title>Gerenciar Salas</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-50 text-gray-900">
    <%@ include file="/WEB-INF/jsp/components/header.jsp" %>
    
    <main class="max-w-6xl mx-auto p-6">
        <div class="flex justify-between items-center mb-6">
            <h1 class="text-3xl font-bold">Gerenciar Salas</h1>
            <a href="<c:url value='/admin/salas/novo'/>" 
               class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded">
                Nova Sala
            </a>
        </div>

        <c:if test="${not empty success}">
            <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded mb-4" data-auto-dismiss="3000">
                ${success}
            </div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4" data-auto-dismiss="3000">
                ${error}
            </div>
        </c:if>
        

 
        <div class="bg-white shadow rounded-lg overflow-hidden">
            <table class="min-w-full divide-y divide-gray-200">
                <thead class="bg-gray-50">
                    <tr>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">ID</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Nome</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Setor</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Valor por Hora</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Capacidade</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Ações</th>
                    </tr>
                </thead>
                <tbody class="bg-white divide-y divide-gray-200">
                    <c:forEach var="sala" items="${salas}">
                        <tr>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">${sala.id}</td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">${sala.nome}</td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">${sala.setor.nome}</td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">R$ ${sala.valorPorHora}/hora</td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">${sala.capacidadeMaxima} pessoas</td>
                            <td class="px-6 py-4 whitespace-nowrap">
                                <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${sala.ativa ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'}">
                                    ${sala.ativa ? 'Ativa' : 'Inativa'}
                                </span>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                                <a href="<c:url value='/admin/salas/editar?id=${sala.id}'/>" 
                                   class="text-blue-600 hover:text-blue-900 mr-3">Editar</a>
                                <form action="<c:url value='/admin/salas/excluir'/>" method="post" class="inline">
                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                    <input type="hidden" name="id" value="${sala.id}" />
                                    <button type="submit" 
                                            class="text-red-600 hover:text-red-900"
                                            onclick="return confirm('Tem certeza que deseja excluir esta sala?')">
                                        Excluir
                                    </button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>

        <div class="mt-6">
            <a href="<c:url value='/admin'/>" 
               class="bg-gray-600 hover:bg-gray-700 text-white px-4 py-2 rounded">
                Voltar
            </a>
        </div>
    </main>
</body>
</html>
