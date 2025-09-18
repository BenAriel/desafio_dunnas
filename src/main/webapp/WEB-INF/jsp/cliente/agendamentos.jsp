<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <title>Meus Agendamentos</title>
    <meta name="server-now" content="${now}" />
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-50 text-gray-900">
    <%@ include file="/WEB-INF/jsp/components/header.jsp" %>
    
    <main class="max-w-6xl mx-auto p-6">
        <div class="flex justify-between items-center mb-6">
            <h1 class="text-3xl font-bold">Meus Agendamentos</h1>
            <a href="<c:url value='/cliente/setores'/>" 
               class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded">
                Nova Solicitação
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
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Sala</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Setor</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Data/Hora Início</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Data/Hora Fim</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Valor Total</th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Ações</th>
                    </tr>
                </thead>
                <tbody class="bg-white divide-y divide-gray-200">
                    <c:forEach var="agendamento" items="${agendamentos}">
                        <tr>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">${agendamento.id}</td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">${agendamento.sala.nome}</td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">${agendamento.sala.setor.nome}</td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900"><span data-datetime="${agendamento.dataHoraInicio}">${agendamento.dataHoraInicio}</span></td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900"><span data-datetime="${agendamento.dataHoraFim}">${agendamento.dataHoraFim}</span></td>
                            <td class="px-6 py-4 whitespace-nowrap">
                                <c:choose>
                                    <c:when test="${agendamento.status == 'SOLICITADO'}">
                                        <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-orange-100 text-orange-800">
                                            Solicitado
                                        </span>
                                    </c:when>
                                    <c:when test="${agendamento.status == 'CONFIRMADO'}">
                                        <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-blue-100 text-blue-800">
                                            Confirmado
                                        </span>
                                    </c:when>
                                    <c:when test="${agendamento.status == 'FINALIZADO'}">
                                        <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">
                                            Finalizado
                                        </span>
                                    </c:when>
                                    <c:when test="${agendamento.status == 'CANCELADO'}">
                                        <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-red-100 text-red-800">
                                            Cancelado
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-gray-100 text-gray-800">
                                            ${agendamento.status}
                                        </span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">R$ ${agendamento.valorTotal}</td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                                <c:choose>
                                    <c:when test="${agendamento.status == 'SOLICITADO'}">
                                        <form action="<c:url value='/cliente/agendamentos/cancelar'/>" method="post" class="inline">
                                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                            <input type="hidden" name="agendamentoId" value="${agendamento.id}" />
                                            <button type="submit" 
                                                    class="text-red-600 hover:text-red-900"
                                                    data-confirm="Tem certeza que deseja cancelar este agendamento?">
                                                Cancelar
                                            </button>
                                        </form>
                                    </c:when>
                                    <c:when test="${agendamento.status == 'CONFIRMADO'}">
                                        <form action="<c:url value='/cliente/agendamentos/cancelar'/>" method="post" class="inline cancel-confirmado" data-inicio="${agendamento.dataHoraInicio}">
                                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                            <input type="hidden" name="agendamentoId" value="${agendamento.id}" />
                                            <button type="submit" 
                                                    class="text-red-600 hover:text-red-900"
                                                    data-confirm="Deseja cancelar este agendamento confirmado? O valor de sinal será estornado do caixa.">
                                                Cancelar
                                            </button>
                                        </form>
                                        <span class="text-gray-500 ml-2">Aguardando finalização</span>
                                    </c:when>
                                    <c:when test="${agendamento.status == 'FINALIZADO'}">
                                        <span class="text-green-600">Concluído</span>
                                    </c:when>
                                    <c:when test="${agendamento.status == 'CANCELADO'}">
                                        <span class="text-red-600">Cancelado</span>
                                    </c:when>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>

        <c:if test="${page != null && page.totalPages > 1}">
            <nav class="mt-6 flex items-center justify-between" aria-label="Paginação">
                <div class="text-sm text-gray-600">
                    Página <span class="font-semibold">${page.number + 1}</span> de <span class="font-semibold">${page.totalPages}</span>
                </div>
                <div class="inline-flex -space-x-px rounded-md shadow-sm" role="group">
                    <c:choose>
                        <c:when test="${page.number > 0}">
                            <a href="<c:url value='/cliente/agendamentos?page=${page.number - 1}&size=${page.size}'/>"
                               class="px-3 py-2 text-sm font-medium border border-gray-300 text-gray-700 bg-white hover:bg-gray-50 rounded-l-md">
                                Anterior
                            </a>
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
                                        <a href="<c:url value='/cliente/agendamentos?page=${i}&size=${page.size}'/>"
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
                                    <a href="<c:url value='/cliente/agendamentos?page=0&size=${page.size}'/>"
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
                                    <a href="<c:url value='/cliente/agendamentos?page=${lastIndex}&size=${page.size}'/>"
                                       class="px-3 py-2 text-sm font-medium border border-gray-300 bg-white text-gray-700 hover:bg-gray-50">${page.totalPages}</a>
                                </c:otherwise>
                            </c:choose>
                        </c:otherwise>
                    </c:choose>

                    <c:choose>
                        <c:when test="${page.number + 1 < page.totalPages}">
                            <a href="<c:url value='/cliente/agendamentos?page=${page.number + 1}&size=${page.size}'/>"
                               class="px-3 py-2 text-sm font-medium border border-gray-300 text-gray-700 bg-white hover:bg-gray-50 rounded-r-md">
                                Próxima
                            </a>
                        </c:when>
                        <c:otherwise>
                            <span class="px-3 py-2 text-sm font-medium border border-gray-200 text-gray-400 bg-gray-100 rounded-r-md cursor-not-allowed">Próxima</span>
                        </c:otherwise>
                    </c:choose>
                </div>
            </nav>
        </c:if>

        <c:if test="${empty agendamentos}">
            <div class="text-center py-12">
                <p class="text-gray-500 text-lg">Você ainda não possui agendamentos.</p>
                <a href="<c:url value='/cliente/setores'/>" 
                   class="mt-4 inline-block bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded">
                    Fazer Primeira Solicitação
                </a>
            </div>
        </c:if>

        <div class="mt-6">
            <a href="<c:url value='/cliente'/>" 
               class="bg-gray-600 hover:bg-gray-700 text-white px-4 py-2 rounded">
                Voltar
            </a>
        </div>
    </main>
    <script defer src="<c:url value='/js/cliente/agendamentos.js'/>"></script>
</body>
</html>
