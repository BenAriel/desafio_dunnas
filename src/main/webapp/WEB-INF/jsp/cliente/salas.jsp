<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <title>Salas Disponíveis</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-50 text-gray-900">
    <%@ include file="/WEB-INF/jsp/components/header.jsp" %>
    
    <main class="max-w-6xl mx-auto p-6">
        <div class="flex justify-between items-center mb-6">
            <h1 class="text-3xl font-bold">Salas Disponíveis</h1>
            <c:if test="${setor != null}">
                <span class="text-lg text-gray-600">Setor: ${setor.nome}</span>
            </c:if>
        </div>

        <div class="bg-white shadow rounded-lg p-4 mb-6">
            <form method="get" action="<c:url value='/cliente/salas'/>" class="flex gap-4 items-end">
                <div class="flex-1">
                    <label for="setorId" class="block text-sm font-medium text-gray-700 mb-2">Filtrar por Setor</label>
                    <select id="setorId" 
                            name="setorId" 
                            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                        <option value="">Todos os setores</option>
                        <c:forEach var="setorOption" items="${setores}">
                            <option value="${setorOption.id}" ${setorId == setorOption.id ? 'selected' : ''}>
                                ${setorOption.nome}
                            </option>
                        </c:forEach>
                    </select>
                </div>
                <button type="submit" 
                        class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded">
                    Filtrar
                </button>
            </form>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            <c:forEach var="sala" items="${salas}">
                <div class="bg-white shadow rounded-lg p-6 hover:shadow-md transition-shadow">
                    <div class="flex items-center justify-between mb-4">
                        <h3 class="text-xl font-semibold text-gray-900">${sala.nome}</h3>
                        <span class="px-2 py-1 text-xs font-semibold rounded-full ${sala.ativa ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'}">
                            ${sala.ativa ? 'Disponível' : 'Indisponível'}
                        </span>
                    </div>
                    
                    <div class="space-y-2 mb-4">
                        <p class="text-sm text-gray-600">
                            <span class="font-medium">Setor:</span> ${sala.setor.nome}
                        </p>
                        <p class="text-sm text-gray-600">
                            <span class="font-medium">Valor:</span> R$ ${sala.valorPorHora}/hora
                        </p>
                        <p class="text-sm text-gray-600">
                            <span class="font-medium">Capacidade:</span> ${sala.capacidadeMaxima} pessoas
                        </p>
                    </div>
                    
                    <div class="flex gap-2">
                        <c:choose>
                            <c:when test="${sala.ativa}">
                                <a href="<c:url value='/cliente/agendamentos/solicitar?salaId=${sala.id}'/>" 
                                   class="flex-1 bg-blue-600 hover:bg-blue-700 text-white text-center px-4 py-2 rounded text-sm">
                                    Solicitar Agendamento
                                </a>
                            </c:when>
                            <c:otherwise>
                                <span class="flex-1 bg-gray-400 text-white text-center px-4 py-2 rounded text-sm cursor-not-allowed">
                                    Indisponível
                                </span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </c:forEach>
        </div>

        <c:if test="${page != null && page.totalPages > 1}">
            <div class="flex justify-end items-center mt-6">
                <nav class="inline-flex -space-x-px rounded-md shadow-sm" role="group" aria-label="Paginação">
                    <c:choose>
                        <c:when test="${page.number > 0}">
                            <a href="<c:url value='/cliente/salas?setorId=${setorId}&page=${page.number - 1}&size=${page.size}'/>"
                               class="px-3 py-2 text-sm font-medium border border-gray-300 text-gray-700 bg-white hover:bg-gray-50 rounded-l-md">Anterior</a>
                        </c:when>
                        <c:otherwise>
                            <span class="px-3 py-2 text-sm font-medium border border-gray-200 text-gray-400 bg-gray-100 rounded-l-md cursor-not-allowed">Anterior</span>
                        </c:otherwise>
                    </c:choose>
                    <c:choose>
                        <c:when test="${page.totalPages <= 3}">
                            <c:forEach var="i" begin="0" end="${page.totalPages - 1}">
                                <c:choose>
                                    <c:when test="${i == page.number}">
                                        <span class="px-3 py-2 text-sm font-medium border border-blue-600 bg-blue-600 text-white">${i + 1}</span>
                                    </c:when>
                                    <c:otherwise>
                                        <a href="<c:url value='/cliente/salas?setorId=${setorId}&page=${i}&size=${page.size}'/>"
                                           class="px-3 py-2 text-sm font-medium border border-gray-300 bg-white text-gray-700 hover:bg-gray-50">${i + 1}</a>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <c:choose>
                                <c:when test="${page.number == 0}">
                                    <span class="px-3 py-2 text-sm font-medium border border-blue-600 bg-blue-600 text-white">1</span>
                                </c:when>
                                <c:otherwise>
                                    <a href="<c:url value='/cliente/salas?setorId=${setorId}&page=0&size=${page.size}'/>"
                                       class="px-3 py-2 text-sm font-medium border border-gray-300 bg-white text-gray-700 hover:bg-gray-50">1</a>
                                </c:otherwise>
                            </c:choose>
                            <span class="px-3 py-2 text-sm font-medium border border-gray-200 bg-gray-100 text-gray-500">…</span>
                            <c:if test="${page.number > 0 && page.number < page.totalPages - 1}">
                                <span class="px-3 py-2 text-sm font-medium border border-blue-600 bg-blue-600 text-white">${page.number + 1}</span>
                                <span class="px-3 py-2 text-sm font-medium border border-gray-200 bg-gray-100 text-gray-500">…</span>
                            </c:if>
                            <c:set var="lastIndex" value="${page.totalPages - 1}" />
                            <c:choose>
                                <c:when test="${page.number == lastIndex}">
                                    <span class="px-3 py-2 text-sm font-medium border border-blue-600 bg-blue-600 text-white">${page.totalPages}</span>
                                </c:when>
                                <c:otherwise>
                                    <a href="<c:url value='/cliente/salas?setorId=${setorId}&page=${lastIndex}&size=${page.size}'/>"
                                       class="px-3 py-2 text-sm font-medium border border-gray-300 bg-white text-gray-700 hover:bg-gray-50">${page.totalPages}</a>
                                </c:otherwise>
                            </c:choose>
                        </c:otherwise>
                    </c:choose>
                    <c:choose>
                        <c:when test="${page.number + 1 < page.totalPages}">
                            <a href="<c:url value='/cliente/salas?setorId=${setorId}&page=${page.number + 1}&size=${page.size}'/>"
                               class="px-3 py-2 text-sm font-medium border border-gray-300 text-gray-700 bg-white hover:bg-gray-50 rounded-r-md">Próxima</a>
                        </c:when>
                        <c:otherwise>
                            <span class="px-3 py-2 text-sm font-medium border border-gray-200 text-gray-400 bg-gray-100 rounded-r-md cursor-not-allowed">Próxima</span>
                        </c:otherwise>
                    </c:choose>
                </nav>
            </div>
        </c:if>

        <c:if test="${empty salas}">
            <div class="text-center py-12">
                <p class="text-gray-500 text-lg">Nenhuma sala encontrada.</p>
            </div>
        </c:if>

        <div class="mt-8">
            <a href="<c:url value='/cliente'/>" 
               class="bg-gray-600 hover:bg-gray-700 text-white px-4 py-2 rounded">
                Voltar
            </a>
        </div>
    </main>
</body>
</html>
