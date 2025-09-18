<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <title>Gerenciar Recepcionistas</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-50 text-gray-900">
    <%@ include file="/WEB-INF/jsp/components/header.jsp" %>
    
    <main class="max-w-6xl mx-auto p-6">
        <div class="flex justify-between items-center mb-6">
            <h1 class="text-3xl font-bold">Gerenciar Recepcionistas</h1>
            <a href="<c:url value='/admin/recepcionistas/novo'/>" 
               class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded">
                Novo Recepcionista
            </a>
        </div>

        <!-- Mensagens de sucesso/erro (flash ou query param) -->
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
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Email</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Matrícula</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Setor</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">CPF</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Ações</th>
                    </tr>
                </thead>
                <tbody class="bg-white divide-y divide-gray-200">
                    <c:forEach var="recepcionista" items="${recepcionistas}">
                        <tr>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">${recepcionista.id}</td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">${recepcionista.usuario.nome}</td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">${recepcionista.usuario.email}</td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">${recepcionista.matricula}</td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">${recepcionista.setor.nome}</td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">${recepcionista.cpf}</td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                                <a href="<c:url value='/admin/recepcionistas/editar?id=${recepcionista.id}'/>" class="text-blue-600 hover:text-blue-800 mr-3">Editar</a>
                                <form action="<c:url value='/admin/recepcionistas/excluir'/>" method="post" class="inline" data-confirm="Confirmar exclusão deste recepcionista?">
                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                    <input type="hidden" name="id" value="${recepcionista.id}" />
                                    <button type="submit" class="text-red-600 hover:text-red-800" data-confirm="Confirmar exclusão deste recepcionista?">Excluir</button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>

        <c:if test="${page != null && page.totalPages > 1}">
            <div class="flex items-center justify-end mt-4">
                <nav class="inline-flex -space-x-px rounded-md shadow-sm" role="group" aria-label="Paginação">
                    <c:choose>
                        <c:when test="${page.number > 0}">
                            <a href="?page=${page.number - 1}&size=${page.size}"
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
                                        <a href="?page=${i}&size=${page.size}"
                                           class="px-3 py-2 text-sm font-medium border border-gray-300 bg-white text-gray-700 hover:bg-gray-50">${i + 1}</a>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <!-- Primeira página -->
                            <c:choose>
                                <c:when test="${page.number == 0}">
                                    <span class="px-3 py-2 text-sm font-medium border border-blue-600 bg-blue-600 text-white">1</span>
                                </c:when>
                                <c:otherwise>
                                    <a href="?page=0&size=${page.size}"
                                       class="px-3 py-2 text-sm font-medium border border-gray-300 bg-white text-gray-700 hover:bg-gray-50">1</a>
                                </c:otherwise>
                            </c:choose>
                            <span class="px-3 py-2 text-sm font-medium border border-gray-200 bg-gray-100 text-gray-500">…</span>
                            <!-- Página atual no meio (se não for primeira nem última) -->
                            <c:if test="${page.number > 0 && page.number < page.totalPages - 1}">
                                <span class="px-3 py-2 text-sm font-medium border border-blue-600 bg-blue-600 text-white">${page.number + 1}</span>
                                <span class="px-3 py-2 text-sm font-medium border border-gray-200 bg-gray-100 text-gray-500">…</span>
                            </c:if>
                            <!-- Última página -->
                            <c:set var="lastIndex" value="${page.totalPages - 1}" />
                            <c:choose>
                                <c:when test="${page.number == lastIndex}">
                                    <span class="px-3 py-2 text-sm font-medium border border-blue-600 bg-blue-600 text-white">${page.totalPages}</span>
                                </c:when>
                                <c:otherwise>
                                    <a href="?page=${lastIndex}&size=${page.size}"
                                       class="px-3 py-2 text-sm font-medium border border-gray-300 bg-white text-gray-700 hover:bg-gray-50">${page.totalPages}</a>
                                </c:otherwise>
                            </c:choose>
                        </c:otherwise>
                    </c:choose>
                    <c:choose>
                        <c:when test="${page.number + 1 < page.totalPages}">
                            <a href="?page=${page.number + 1}&size=${page.size}"
                               class="px-3 py-2 text-sm font-medium border border-gray-300 text-gray-700 bg-white hover:bg-gray-50 rounded-r-md">Próxima</a>
                        </c:when>
                        <c:otherwise>
                            <span class="px-3 py-2 text-sm font-medium border border-gray-200 text-gray-400 bg-gray-100 rounded-r-md cursor-not-allowed">Próxima</span>
                        </c:otherwise>
                    </c:choose>
                </nav>
            </div>
        </c:if>

        <div class="mt-6">
            <a href="<c:url value='/admin'/>" 
               class="bg-gray-600 hover:bg-gray-700 text-white px-4 py-2 rounded">
                Voltar
            </a>
        </div>
    </main>
</body>
</html>

