<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <title>Relatório Geral</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-50 text-gray-900">
    <%@ include file="/WEB-INF/jsp/components/header.jsp" %>
    <main class="max-w-7xl mx-auto p-6">
        <h1 class="text-3xl font-bold mb-6 text-center">Relatório Geral</h1>

        <c:if test="${not empty error}">
            <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4" data-auto-dismiss="3000">
                ${error}
            </div>
        </c:if>

    <form method="get" class="bg-white p-4 rounded shadow mb-6 grid grid-cols-1 md:grid-cols-7 gap-4">
            <div class="md:col-span-2">
                <label class="block text-sm font-medium text-gray-700 mb-2">Setor (opcional)</label>
                <select name="setorId" class="w-full border rounded px-3 py-2">
                    <option value="">Todos os setores</option>
                    <c:forEach var="s" items="${setores}">
                        <option value="${s.id}" ${setorId == s.id ? 'selected' : ''}>${s.nome}</option>
                    </c:forEach>
                </select>
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Data Início (opcional)</label>
                <input type="date" name="dataInicio" value="${dataInicio}" class="w-full border rounded px-3 py-2"/>
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Data Fim (opcional)</label>
                <input type="date" name="dataFim" value="${dataFim}" class="w-full border rounded px-3 py-2"/>
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Status</label>
                <select name="status" class="w-full border rounded px-3 py-2">
                    <option value="">Todos</option>
                    <option value="SOLICITADO" ${status == 'SOLICITADO' ? 'selected' : ''}>Solicitado</option>
                    <option value="CONFIRMADO" ${status == 'CONFIRMADO' ? 'selected' : ''}>Confirmado</option>
                    <option value="FINALIZADO" ${status == 'FINALIZADO' ? 'selected' : ''}>Finalizado</option>
                    <option value="CANCELADO" ${status == 'CANCELADO' ? 'selected' : ''}>Cancelado</option>
                </select>
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Cliente</label>
                <select name="clienteId" class="w-full border rounded px-3 py-2">
                    <option value="">Todos</option>
                    <c:forEach var="c" items="${clientes}">
                        <option value="${c.id}" ${clienteId == c.id ? 'selected' : ''}>${c.usuario.nome}</option>
                    </c:forEach>
                </select>
            </div>
            <div class="flex items-end">
                <button class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded">Aplicar</button>
            </div>
        </form>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-6">
            <div class="bg-white shadow rounded-lg p-4">
                <div class="text-sm text-gray-500">Total em Caixa</div>
                <div class="text-2xl font-bold mt-1">R$ ${valorCaixa != null ? valorCaixa : '0,00'}</div>
            </div>
            <div class="bg-white shadow rounded-lg p-4">
                <div class="text-sm text-gray-500">Qtd. Agendamentos</div>
                <div class="text-2xl font-bold mt-1">${agPage != null ? agPage.totalElements : (agendamentos != null ? agendamentos.size() : 0)}</div>
            </div>
            <div class="bg-white shadow rounded-lg p-4">
                <div class="text-sm text-gray-500">Qtd. Transações</div>
                <div class="text-2xl font-bold mt-1">${txPage != null ? txPage.totalElements : (transacoes != null ? transacoes.size() : 0)}</div>
            </div>
        </div>

        <div class="bg-white shadow rounded-lg overflow-hidden mb-8">
            <div class="px-6 py-4 border-b font-semibold">Agendamentos</div>
            <c:choose>
                <c:when test="${not empty agendamentos}">
                    <table class="min-w-full divide-y divide-gray-200">
                        <thead class="bg-gray-50">
                            <tr>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">ID</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Setor</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Sala</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Cliente</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Início</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Fim</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Valor Total</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                            </tr>
                        </thead>
                        <tbody class="bg-white divide-y divide-gray-200">
                            <c:forEach var="a" items="${agendamentos}">
                                <tr>
                                    <td class="px-6 py-4 text-sm">${a.id}</td>
                                    <td class="px-6 py-4 text-sm">${a.sala.setor.nome}</td>
                                    <td class="px-6 py-4 text-sm">${a.sala.nome}</td>
                                    <td class="px-6 py-4 text-sm">${a.cliente.usuario.nome}</td>
                                    <td class="px-6 py-4 text-sm"><span data-datetime="${a.dataHoraInicio}">${a.dataHoraInicio}</span></td>
                                    <td class="px-6 py-4 text-sm"><span data-datetime="${a.dataHoraFim}">${a.dataHoraFim}</span></td>
                                    <td class="px-6 py-4 text-sm">R$ ${a.valorTotal}</td>
                                    <td class="px-6 py-4 text-sm">
                                        <c:choose>
                                            <c:when test="${a.status == 'SOLICITADO'}"><span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-orange-100 text-orange-800">Solicitado</span></c:when>
                                            <c:when test="${a.status == 'CONFIRMADO'}"><span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">Confirmado</span></c:when>
                                            <c:when test="${a.status == 'FINALIZADO'}"><span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-blue-100 text-blue-800">Finalizado</span></c:when>
                                            <c:when test="${a.status == 'CANCELADO'}"><span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-red-100 text-red-800">Cancelado</span></c:when>
                                            <c:otherwise><span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-gray-100 text-gray-800">${a.status}</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:when>
                <c:otherwise>
                    <div class="px-6 py-4 text-gray-500">Nenhum agendamento encontrado para os filtros informados.</div>
                </c:otherwise>
            </c:choose>
        </div>
        <c:if test="${agPage != null && agPage.totalPages > 1}">
            <div class="flex items-center justify-end mt-4 px-6 pb-6">
                <nav class="inline-flex -space-x-px rounded-md shadow-sm" role="group" aria-label="Paginação agendamentos">
                    <c:choose>
                        <c:when test="${agPage.number > 0}">
                            <a class="px-3 py-2 text-sm font-medium border border-gray-300 text-gray-700 bg-white hover:bg-gray-50 rounded-l-md"
                               href="?setorId=${setorId}&dataInicio=${dataInicio}&dataFim=${dataFim}&status=${status}&clienteId=${clienteId}&agPage=${agPage.number - 1}&agSize=${agPage.size}&histPage=${histPage != null ? histPage.number : 0}&histSize=${histPage != null ? histPage.size : agPage.size}&txPage=${txPage != null ? txPage.number : 0}&txSize=${txPage != null ? txPage.size : agPage.size}">Anterior</a>
                        </c:when>
                        <c:otherwise>
                            <span class="px-3 py-2 text-sm font-medium border border-gray-200 text-gray-400 bg-gray-100 rounded-l-md cursor-not-allowed">Anterior</span>
                        </c:otherwise>
                    </c:choose>
                    <c:choose>
                        <c:when test="${agPage.totalPages <= 3}">
                            <c:forEach var="i" begin="0" end="${agPage.totalPages - 1}">
                                <c:choose>
                                    <c:when test="${i == agPage.number}">
                                        <span class="px-3 py-2 text-sm font-medium border border-blue-600 bg-blue-600 text-white">${i + 1}</span>
                                    </c:when>
                                    <c:otherwise>
                                        <a href="?setorId=${setorId}&dataInicio=${dataInicio}&dataFim=${dataFim}&status=${status}&clienteId=${clienteId}&agPage=${i}&agSize=${agPage.size}&histPage=${histPage != null ? histPage.number : 0}&histSize=${histPage != null ? histPage.size : agPage.size}&txPage=${txPage != null ? txPage.number : 0}&txSize=${txPage != null ? txPage.size : agPage.size}"
                                           class="px-3 py-2 text-sm font-medium border border-gray-300 bg-white text-gray-700 hover:bg-gray-50">${i + 1}</a>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <!-- Primeira página -->
                            <c:choose>
                                <c:when test="${agPage.number == 0}">
                                    <span class="px-3 py-2 text-sm font-medium border border-blue-600 bg-blue-600 text-white">1</span>
                                </c:when>
                                <c:otherwise>
                                    <a href="?setorId=${setorId}&dataInicio=${dataInicio}&dataFim=${dataFim}&status=${status}&clienteId=${clienteId}&agPage=0&agSize=${agPage.size}&histPage=${histPage != null ? histPage.number : 0}&histSize=${histPage != null ? histPage.size : agPage.size}&txPage=${txPage != null ? txPage.number : 0}&txSize=${txPage != null ? txPage.size : agPage.size}"
                                       class="px-3 py-2 text-sm font-medium border border-gray-300 bg-white text-gray-700 hover:bg-gray-50">1</a>
                                </c:otherwise>
                            </c:choose>
                            <span class="px-3 py-2 text-sm font-medium border border-gray-200 bg-gray-100 text-gray-500">…</span>
                            <c:if test="${agPage.number > 0 && agPage.number < agPage.totalPages - 1}">
                                <span class="px-3 py-2 text-sm font-medium border border-blue-600 bg-blue-600 text-white">${agPage.number + 1}</span>
                                <span class="px-3 py-2 text-sm font-medium border border-gray-200 bg-gray-100 text-gray-500">…</span>
                            </c:if>
                            <c:set var="lastIndex" value="${agPage.totalPages - 1}" />
                            <c:choose>
                                <c:when test="${agPage.number == lastIndex}">
                                    <span class="px-3 py-2 text-sm font-medium border border-blue-600 bg-blue-600 text-white">${agPage.totalPages}</span>
                                </c:when>
                                <c:otherwise>
                                    <a href="?setorId=${setorId}&dataInicio=${dataInicio}&dataFim=${dataFim}&status=${status}&clienteId=${clienteId}&agPage=${lastIndex}&agSize=${agPage.size}&histPage=${histPage != null ? histPage.number : 0}&histSize=${histPage != null ? histPage.size : agPage.size}&txPage=${txPage != null ? txPage.number : 0}&txSize=${txPage != null ? txPage.size : agPage.size}"
                                       class="px-3 py-2 text-sm font-medium border border-gray-300 bg-white text-gray-700 hover:bg-gray-50">${agPage.totalPages}</a>
                                </c:otherwise>
                            </c:choose>
                        </c:otherwise>
                    </c:choose>
                    <c:choose>
                        <c:when test="${agPage.number + 1 < agPage.totalPages}">
                            <a class="px-3 py-2 text-sm font-medium border border-gray-300 text-gray-700 bg-white hover:bg-gray-50 rounded-r-md"
                               href="?setorId=${setorId}&dataInicio=${dataInicio}&dataFim=${dataFim}&status=${status}&clienteId=${clienteId}&agPage=${agPage.number + 1}&agSize=${agPage.size}&histPage=${histPage != null ? histPage.number : 0}&histSize=${histPage != null ? histPage.size : agPage.size}&txPage=${txPage != null ? txPage.number : 0}&txSize=${txPage != null ? txPage.size : agPage.size}">Próxima</a>
                        </c:when>
                        <c:otherwise>
                            <span class="px-3 py-2 text-sm font-medium border border-gray-200 text-gray-400 bg-gray-100 rounded-r-md cursor-not-allowed">Próxima</span>
                        </c:otherwise>
                    </c:choose>
                </nav>
            </div>
        </c:if>
       

        <div class="bg-white shadow rounded-lg overflow-hidden mb-8">
            <div class="px-6 py-4 border-b font-semibold">Histórico de mudanças</div>
            <c:choose>
                <c:when test="${not empty historicos}">
                    <table class="min-w-full divide-y divide-gray-200">
                        <thead class="bg-gray-50">
                            <tr>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Agendamento</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Sala (Setor)</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Cliente</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">De</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Para</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Quando</th>
                            </tr>
                        </thead>
                        <tbody class="bg-white divide-y divide-gray-200">
                            <c:forEach var="h" items="${historicos}">
                                <tr>
                                    <td class="px-6 py-4 text-sm">${h.agendamento.id}</td>
                                    <td class="px-6 py-4 text-sm">${h.agendamento.sala.nome} (${h.agendamento.sala.setor.nome})</td>
                                    <td class="px-6 py-4 text-sm">${h.agendamento.cliente.usuario.nome}</td>
                                    <td class="px-6 py-4 text-sm">
                                        <c:choose>
                                            <c:when test="${h.statusAnterior == 'SOLICITADO'}"><span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-orange-100 text-orange-800">Solicitado</span></c:when>
                                            <c:when test="${h.statusAnterior == 'CONFIRMADO'}"><span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">Confirmado</span></c:when>
                                            <c:when test="${h.statusAnterior == 'FINALIZADO'}"><span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-blue-100 text-blue-800">Finalizado</span></c:when>
                                            <c:when test="${h.statusAnterior == 'CANCELADO'}"><span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-red-100 text-red-800">Cancelado</span></c:when>
                                            <c:otherwise><span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-gray-100 text-gray-800">${h.statusAnterior}</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="px-6 py-4 text-sm">
                                        <c:choose>
                                            <c:when test="${h.statusNovo == 'SOLICITADO'}"><span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-orange-100 text-orange-800">Solicitado</span></c:when>
                                            <c:when test="${h.statusNovo == 'CONFIRMADO'}"><span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">Confirmado</span></c:when>
                                            <c:when test="${h.statusNovo == 'FINALIZADO'}"><span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-blue-100 text-blue-800">Finalizado</span></c:when>
                                            <c:when test="${h.statusNovo == 'CANCELADO'}"><span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-red-100 text-red-800">Cancelado</span></c:when>
                                            <c:otherwise><span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-gray-100 text-gray-800">${h.statusNovo}</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="px-6 py-4 text-sm"><span data-datetime="${h.dataMudanca}">${h.dataMudanca}</span></td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:when>
                <c:otherwise>
                    <div class="px-6 py-4 text-gray-500">Nenhum histórico encontrado para os filtros informados.</div>
                </c:otherwise>
            </c:choose>
        </div>
        <c:if test="${histPage != null && histPage.totalPages > 1}">
            <div class="flex items-center justify-end mt-4 px-6 pb-6">
                <nav class="inline-flex -space-x-px rounded-md shadow-sm" role="group" aria-label="Paginação histórico">
                    <c:choose>
                        <c:when test="${histPage.number > 0}">
                            <a class="px-3 py-2 text-sm font-medium border border-gray-300 text-gray-700 bg-white hover:bg-gray-50 rounded-l-md"
                               href="?setorId=${setorId}&dataInicio=${dataInicio}&dataFim=${dataFim}&status=${status}&clienteId=${clienteId}&agPage=${agPage != null ? agPage.number : 0}&agSize=${agPage != null ? agPage.size : histPage.size}&histPage=${histPage.number - 1}&histSize=${histPage.size}&txPage=${txPage != null ? txPage.number : 0}&txSize=${txPage != null ? txPage.size : histPage.size}">Anterior</a>
                        </c:when>
                        <c:otherwise>
                            <span class="px-3 py-2 text-sm font-medium border border-gray-200 text-gray-400 bg-gray-100 rounded-l-md cursor-not-allowed">Anterior</span>
                        </c:otherwise>
                    </c:choose>
                    <c:choose>
                        <c:when test="${histPage.totalPages <= 3}">
                            <c:forEach var="i" begin="0" end="${histPage.totalPages - 1}">
                                <c:choose>
                                    <c:when test="${i == histPage.number}">
                                        <span class="px-3 py-2 text-sm font-medium border border-blue-600 bg-blue-600 text-white">${i + 1}</span>
                                    </c:when>
                                    <c:otherwise>
                                        <a href="?setorId=${setorId}&dataInicio=${dataInicio}&dataFim=${dataFim}&status=${status}&clienteId=${clienteId}&agPage=${agPage != null ? agPage.number : 0}&agSize=${agPage != null ? agPage.size : histPage.size}&histPage=${i}&histSize=${histPage.size}&txPage=${txPage != null ? txPage.number : 0}&txSize=${txPage != null ? txPage.size : histPage.size}"
                                           class="px-3 py-2 text-sm font-medium border border-gray-300 bg-white text-gray-700 hover:bg-gray-50">${i + 1}</a>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <c:choose>
                                <c:when test="${histPage.number == 0}">
                                    <span class="px-3 py-2 text-sm font-medium border border-blue-600 bg-blue-600 text-white">1</span>
                                </c:when>
                                <c:otherwise>
                                    <a href="?setorId=${setorId}&dataInicio=${dataInicio}&dataFim=${dataFim}&status=${status}&clienteId=${clienteId}&agPage=${agPage != null ? agPage.number : 0}&agSize=${agPage != null ? agPage.size : histPage.size}&histPage=0&histSize=${histPage.size}&txPage=${txPage != null ? txPage.number : 0}&txSize=${txPage != null ? txPage.size : histPage.size}"
                                       class="px-3 py-2 text-sm font-medium border border-gray-300 bg-white text-gray-700 hover:bg-gray-50">1</a>
                                </c:otherwise>
                            </c:choose>
                            <span class="px-3 py-2 text-sm font-medium border border-gray-200 bg-gray-100 text-gray-500">…</span>
                            <c:if test="${histPage.number > 0 && histPage.number < histPage.totalPages - 1}">
                                <span class="px-3 py-2 text-sm font-medium border border-blue-600 bg-blue-600 text-white">${histPage.number + 1}</span>
                                <span class="px-3 py-2 text-sm font-medium border border-gray-200 bg-gray-100 text-gray-500">…</span>
                            </c:if>
                            <c:set var="lastIndex" value="${histPage.totalPages - 1}" />
                            <c:choose>
                                <c:when test="${histPage.number == lastIndex}">
                                    <span class="px-3 py-2 text-sm font-medium border border-blue-600 bg-blue-600 text-white">${histPage.totalPages}</span>
                                </c:when>
                                <c:otherwise>
                                    <a href="?setorId=${setorId}&dataInicio=${dataInicio}&dataFim=${dataFim}&status=${status}&clienteId=${clienteId}&agPage=${agPage != null ? agPage.number : 0}&agSize=${agPage != null ? agPage.size : histPage.size}&histPage=${lastIndex}&histSize=${histPage.size}&txPage=${txPage != null ? txPage.number : 0}&txSize=${txPage != null ? txPage.size : histPage.size}"
                                       class="px-3 py-2 text-sm font-medium border border-gray-300 bg-white text-gray-700 hover:bg-gray-50">${histPage.totalPages}</a>
                                </c:otherwise>
                            </c:choose>
                        </c:otherwise>
                    </c:choose>
                    <c:choose>
                        <c:when test="${histPage.number + 1 < histPage.totalPages}">
                            <a class="px-3 py-2 text-sm font-medium border border-gray-300 text-gray-700 bg-white hover:bg-gray-50 rounded-r-md"
                               href="?setorId=${setorId}&dataInicio=${dataInicio}&dataFim=${dataFim}&status=${status}&clienteId=${clienteId}&agPage=${agPage != null ? agPage.number : 0}&agSize=${agPage != null ? agPage.size : histPage.size}&histPage=${histPage.number + 1}&histSize=${histPage.size}&txPage=${txPage != null ? txPage.number : 0}&txSize=${txPage != null ? txPage.size : histPage.size}">Próxima</a>
                        </c:when>
                        <c:otherwise>
                            <span class="px-3 py-2 text-sm font-medium border border-gray-200 text-gray-400 bg-gray-100 rounded-r-md cursor-not-allowed">Próxima</span>
                        </c:otherwise>
                    </c:choose>
                </nav>
            </div>
        </c:if>

        <div class="bg-white shadow rounded-lg overflow-hidden mb-8">
            <div class="px-6 py-4 border-b font-semibold">Transações Confirmadas</div>
            <c:choose>
                <c:when test="${not empty transacoes}">
                    <table class="min-w-full divide-y divide-gray-200">
                        <thead class="bg-gray-50">
                            <tr>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">ID</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Agendamento</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Tipo</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Cliente</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Valor</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Data</th>
                            </tr>
                        </thead>
                        <tbody class="bg-white divide-y divide-gray-200">
                            <c:forEach var="t" items="${transacoes}">
                                <tr>
                                    <td class="px-6 py-4 text-sm">${t.id}</td>
                                    <td class="px-6 py-4 text-sm">${t.agendamento.id}</td>
                                    <td class="px-6 py-4 text-sm">${t.tipo}</td>
                                    <td class="px-6 py-4 text-sm">${t.agendamento.cliente.usuario.nome}</td>
                                    <td class="px-6 py-4 text-sm">R$ ${t.valor}</td>
                                    <td class="px-6 py-4 text-sm"><span data-datetime="${t.dataTransacao}">${t.dataTransacao}</span></td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:when>
                <c:otherwise>
                    <div class="px-6 py-4 text-gray-500">Nenhuma transação encontrada para os filtros informados.</div>
                </c:otherwise>
            </c:choose>
        </div>
        <c:if test="${txPage != null && txPage.totalPages > 1}">
            <div class="flex items-center justify-end mt-4 px-6 pb-6">
                <nav class="inline-flex -space-x-px rounded-md shadow-sm" role="group" aria-label="Paginação transações">
                    <c:choose>
                        <c:when test="${txPage.number > 0}">
                            <a class="px-3 py-2 text-sm font-medium border border-gray-300 text-gray-700 bg-white hover:bg-gray-50 rounded-l-md"
                               href="?setorId=${setorId}&dataInicio=${dataInicio}&dataFim=${dataFim}&status=${status}&clienteId=${clienteId}&agPage=${agPage != null ? agPage.number : 0}&agSize=${agPage != null ? agPage.size : txPage.size}&histPage=${histPage != null ? histPage.number : 0}&histSize=${histPage != null ? histPage.size : txPage.size}&txPage=${txPage.number - 1}&txSize=${txPage.size}">Anterior</a>
                        </c:when>
                        <c:otherwise>
                            <span class="px-3 py-2 text-sm font-medium border border-gray-200 text-gray-400 bg-gray-100 rounded-l-md cursor-not-allowed">Anterior</span>
                        </c:otherwise>
                    </c:choose>
                    <c:choose>
                        <c:when test="${txPage.totalPages <= 3}">
                            <c:forEach var="i" begin="0" end="${txPage.totalPages - 1}">
                                <c:choose>
                                    <c:when test="${i == txPage.number}">
                                        <span class="px-3 py-2 text-sm font-medium border border-blue-600 bg-blue-600 text-white">${i + 1}</span>
                                    </c:when>
                                    <c:otherwise>
                                        <a href="?setorId=${setorId}&dataInicio=${dataInicio}&dataFim=${dataFim}&status=${status}&clienteId=${clienteId}&agPage=${agPage != null ? agPage.number : 0}&agSize=${agPage != null ? agPage.size : txPage.size}&histPage=${histPage != null ? histPage.number : 0}&histSize=${histPage != null ? histPage.size : txPage.size}&txPage=${i}&txSize=${txPage.size}"
                                           class="px-3 py-2 text-sm font-medium border border-gray-300 bg-white text-gray-700 hover:bg-gray-50">${i + 1}</a>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <c:choose>
                                <c:when test="${txPage.number == 0}">
                                    <span class="px-3 py-2 text-sm font-medium border border-blue-600 bg-blue-600 text-white">1</span>
                                </c:when>
                                <c:otherwise>
                                    <a href="?setorId=${setorId}&dataInicio=${dataInicio}&dataFim=${dataFim}&status=${status}&clienteId=${clienteId}&agPage=${agPage != null ? agPage.number : 0}&agSize=${agPage != null ? agPage.size : txPage.size}&histPage=${histPage != null ? histPage.number : 0}&histSize=${histPage != null ? histPage.size : txPage.size}&txPage=0&txSize=${txPage.size}"
                                       class="px-3 py-2 text-sm font-medium border border-gray-300 bg-white text-gray-700 hover:bg-gray-50">1</a>
                                </c:otherwise>
                            </c:choose>
                            <span class="px-3 py-2 text-sm font-medium border border-gray-200 bg-gray-100 text-gray-500">…</span>
                            <c:if test="${txPage.number > 0 && txPage.number < txPage.totalPages - 1}">
                                <span class="px-3 py-2 text-sm font-medium border border-blue-600 bg-blue-600 text-white">${txPage.number + 1}</span>
                                <span class="px-3 py-2 text-sm font-medium border border-gray-200 bg-gray-100 text-gray-500">…</span>
                            </c:if>
                            <c:set var="lastIndex" value="${txPage.totalPages - 1}" />
                            <c:choose>
                                <c:when test="${txPage.number == lastIndex}">
                                    <span class="px-3 py-2 text-sm font-medium border border-blue-600 bg-blue-600 text-white">${txPage.totalPages}</span>
                                </c:when>
                                <c:otherwise>
                                    <a href="?setorId=${setorId}&dataInicio=${dataInicio}&dataFim=${dataFim}&status=${status}&clienteId=${clienteId}&agPage=${agPage != null ? agPage.number : 0}&agSize=${agPage != null ? agPage.size : txPage.size}&histPage=${histPage != null ? histPage.number : 0}&histSize=${histPage != null ? histPage.size : txPage.size}&txPage=${lastIndex}&txSize=${txPage.size}"
                                       class="px-3 py-2 text-sm font-medium border border-gray-300 bg-white text-gray-700 hover:bg-gray-50">${txPage.totalPages}</a>
                                </c:otherwise>
                            </c:choose>
                        </c:otherwise>
                    </c:choose>
                    <c:choose>
                        <c:when test="${txPage.number + 1 < txPage.totalPages}">
                            <a class="px-3 py-2 text-sm font-medium border border-gray-300 text-gray-700 bg-white hover:bg-gray-50 rounded-r-md"
                               href="?setorId=${setorId}&dataInicio=${dataInicio}&dataFim=${dataFim}&status=${status}&clienteId=${clienteId}&agPage=${agPage != null ? agPage.number : 0}&agSize=${agPage != null ? agPage.size : txPage.size}&histPage=${histPage != null ? histPage.number : 0}&histSize=${histPage != null ? histPage.size : txPage.size}&txPage=${txPage.number + 1}&txSize=${txPage.size}">Próxima</a>
                        </c:when>
                        <c:otherwise>
                            <span class="px-3 py-2 text-sm font-medium border border-gray-200 text-gray-400 bg-gray-100 rounded-r-md cursor-not-allowed">Próxima</span>
                        </c:otherwise>
                    </c:choose>
                </nav>
            </div>
        </c:if>
        <div class="mt-8">
            <a href="<c:url value='/admin'/>" 
               class="bg-gray-600 hover:bg-gray-700 text-white px-4 py-2 rounded">
                Voltar
            </a>
        </div>
    </main>
</body>
</html>
