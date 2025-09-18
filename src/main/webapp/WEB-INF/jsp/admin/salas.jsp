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
        <form method="get" action="<c:url value='/admin/salas'/>" class="mb-4 bg-white p-4 rounded shadow flex items-end gap-4">
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Setor</label>
                <select name="setorId" class="w-full border rounded px-3 py-2">
                    <option value="">Todos os setores</option>
                    <c:forEach var="s" items="${setores}">
                        <option value="${s.id}" <c:if test='${setorId == s.id}'>selected</c:if>>${s.nome}</option>
                    </c:forEach>
                </select>
            </div>
            <div>
              
            </div>
            <button type="submit" class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded">Filtrar</button>
        </form>

 
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
                        data-confirm="Tem certeza que deseja excluir esta sala?">
                                        Excluir
                                    </button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>

        <div class="flex items-center justify-between mt-6">
            <a href="<c:url value='/admin'/>" 
               class="bg-gray-600 hover:bg-gray-700 text-white px-4 py-2 rounded">
                Voltar
            </a>
            <c:if test="${page != null && page.totalPages > 1}">
                <nav class="inline-flex -space-x-px rounded-md shadow-sm" role="group" aria-label="Paginação">
                    <c:choose>
                        <c:when test="${page.number > 0}">
                            <c:url var="prevUrl" value="/admin/salas">
                                <c:param name="page" value="${page.number - 1}"/>
                                <c:param name="size" value="${page.size}"/>
                                <c:if test="${not empty setorId}">
                                    <c:param name="setorId" value="${setorId}"/>
                                </c:if>
                            </c:url>
                            <a href="${prevUrl}"
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
                                        <c:url var="pageUrl" value="/admin/salas">
                                            <c:param name="page" value="${i}"/>
                                            <c:param name="size" value="${page.size}"/>
                                            <c:if test="${not empty setorId}">
                                                <c:param name="setorId" value="${setorId}"/>
                                            </c:if>
                                        </c:url>
                                        <a href="${pageUrl}" class="px-3 py-2 text-sm font-medium border border-gray-300 bg-white text-gray-700 hover:bg-gray-50">${i + 1}</a>
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
                                    <c:url var="firstUrl" value="/admin/salas">
                                        <c:param name="page" value="0"/>
                                        <c:param name="size" value="${page.size}"/>
                                        <c:if test="${not empty setorId}">
                                            <c:param name="setorId" value="${setorId}"/>
                                        </c:if>
                                    </c:url>
                                    <a href="${firstUrl}" class="px-3 py-2 text-sm font-medium border border-gray-300 bg-white text-gray-700 hover:bg-gray-50">1</a>
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
                                    <c:url var="lastUrl" value="/admin/salas">
                                        <c:param name="page" value="${lastIndex}"/>
                                        <c:param name="size" value="${page.size}"/>
                                        <c:if test="${not empty setorId}">
                                            <c:param name="setorId" value="${setorId}"/>
                                        </c:if>
                                    </c:url>
                                    <a href="${lastUrl}" class="px-3 py-2 text-sm font-medium border border-gray-300 bg-white text-gray-700 hover:bg-gray-50">${page.totalPages}</a>
                                </c:otherwise>
                            </c:choose>
                        </c:otherwise>
                    </c:choose>
                    <c:choose>
                        <c:when test="${page.number + 1 < page.totalPages}">
                            <c:url var="nextUrl" value="/admin/salas">
                                <c:param name="page" value="${page.number + 1}"/>
                                <c:param name="size" value="${page.size}"/>
                                <c:if test="${not empty setorId}">
                                    <c:param name="setorId" value="${setorId}"/>
                                </c:if>
                            </c:url>
                            <a href="${nextUrl}"
                               class="px-3 py-2 text-sm font-medium border border-gray-300 text-gray-700 bg-white hover:bg-gray-50 rounded-r-md">Próxima</a>
                        </c:when>
                        <c:otherwise>
                            <span class="px-3 py-2 text-sm font-medium border border-gray-200 text-gray-400 bg-gray-100 rounded-r-md cursor-not-allowed">Próxima</span>
                        </c:otherwise>
                    </c:choose>
                </nav>
            </c:if>
        </div>
    </main>
</body>
</html>
