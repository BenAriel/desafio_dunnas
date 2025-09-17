<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <title>Relatórios do Setor</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-50 text-gray-900">
    <%@ include file="/WEB-INF/jsp/components/header.jsp" %>
    
    <main class="max-w-4xl mx-auto p-6">
        <h1 class="text-3xl font-bold mb-6">Relatórios do Setor</h1>

        <div class="bg-white shadow rounded-lg p-6 mb-6">
            <h2 class="text-xl font-semibold mb-4">Informações do Setor</h2>
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div class="bg-blue-50 p-4 rounded-lg">
                    <h3 class="text-sm font-medium text-blue-600">Nome do Setor</h3>
                    <p class="text-2xl font-bold text-blue-900">${setor.nome}</p>
                </div>
                <div class="bg-green-50 p-4 rounded-lg">
                    <h3 class="text-sm font-medium text-green-600">Valor em Caixa</h3>
                    <p class="text-2xl font-bold text-green-900">R$ ${setor.caixa}</p>
                </div>
                <div class="bg-purple-50 p-4 rounded-lg">
                    <h3 class="text-sm font-medium text-purple-600">Status</h3>
                    <p class="text-2xl font-bold text-purple-900">${setor.aberto ? 'Aberto' : 'Fechado'}</p>
                </div>
            </div>
        </div>

        <div class="bg-white shadow rounded-lg p-6 mb-6">
            <h2 class="text-xl font-semibold mb-4">Ações do Setor</h2>
            <div class="flex gap-4">
                <c:choose>
                    <c:when test="${setor.aberto}">
                        <a href="<c:url value='/recepcionista/setor/fechar?setorId=${setor.id}'/>" 
                           class="bg-red-600 hover:bg-red-700 text-white px-4 py-2 rounded">
                            Fechar Setor
                        </a>
                    </c:when>
                    <c:otherwise>
                        <a href="<c:url value='/recepcionista/setor/abrir?setorId=${setor.id}'/>" 
                           class="bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded">
                            Abrir Setor
                        </a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>


        <!-- Filtros de Relatório -->
        <div class="bg-white shadow rounded-lg p-6 mb-6">
            <h2 class="text-xl font-semibold mb-4">Filtros de Relatório</h2>
            <form method="get" action="<c:url value='/recepcionista/relatorios'/>" class="grid grid-cols-1 md:grid-cols-5 gap-4">
                <input type="hidden" name="setorId" value="${setor.id}" />
                
                <div>
                    <label for="dataInicio" class="block text-sm font-medium text-gray-700 mb-2">Data Início</label>
                    <input type="date" id="dataInicio" name="dataInicio" value="${dataInicio}"
                           class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                </div>
                
                <div>
                    <label for="dataFim" class="block text-sm font-medium text-gray-700 mb-2">Data Fim</label>
                    <input type="date" id="dataFim" name="dataFim" value="${dataFim}"
                           class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                </div>

                <div>
                    <label for="status" class="block text-sm font-medium text-gray-700 mb-2">Status</label>
                    <select id="status" name="status" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                        <option value="">Todos</option>
                        <option value="SOLICITADO" ${status == 'SOLICITADO' ? 'selected' : ''}>Solicitado</option>
                        <option value="CONFIRMADO" ${status == 'CONFIRMADO' ? 'selected' : ''}>Confirmado</option>
                        <option value="FINALIZADO" ${status == 'FINALIZADO' ? 'selected' : ''}>Finalizado</option>
                        <option value="CANCELADO" ${status == 'CANCELADO' ? 'selected' : ''}>Cancelado</option>
                    </select>
                </div>

                <div>
                    <label for="clienteId" class="block text-sm font-medium text-gray-700 mb-2">Cliente</label>
                    <select id="clienteId" name="clienteId" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                        <option value="">Todos</option>
                        <c:forEach var="c" items="${clientes}">
                            <option value="${c.id}" ${clienteId == c.id ? 'selected' : ''}>${c.usuario.nome}</option>
                        </c:forEach>
                    </select>
                </div>
                
                <div class="flex items-end">
                    <button type="submit" 
                            class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded">
                        Filtrar
                    </button>
                </div>
            </form>
        </div>

        <c:if test="${not empty agendamentos}">
            <div class="bg-white shadow rounded-lg p-6 mb-6">
                <h2 class="text-xl font-semibold mb-4">Agendamentos no período</h2>
                <div class="overflow-x-auto">
                    <table class="min-w-full divide-y divide-gray-200">
                        <thead class="bg-gray-50">
                            <tr>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">ID</th>
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
                                    <td class="px-6 py-4 text-sm">${a.sala.nome}</td>
                                    <td class="px-6 py-4 text-sm">${a.cliente.usuario.nome}</td>
                                    <td class="px-6 py-4 text-sm"><span data-datetime="${a.dataHoraInicio}">${a.dataHoraInicio}</span></td>
                                    <td class="px-6 py-4 text-sm"><span data-datetime="${a.dataHoraFim}">${a.dataHoraFim}</span></td>
                                    <td class="px-6 py-4 text-sm">R$ ${a.valorTotal}</td>
                                    <td class="px-6 py-4 text-sm">
                                        <c:choose>
                                            <c:when test="${a.status == 'SOLICITADO'}">
                                                <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-orange-100 text-orange-800">Solicitado</span>
                                            </c:when>
                                            <c:when test="${a.status == 'CONFIRMADO'}">
                                                <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">Confirmado</span>
                                            </c:when>
                                            <c:when test="${a.status == 'FINALIZADO'}">
                                                <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-blue-100 text-blue-800">Finalizado</span>
                                            </c:when>
                                            <c:when test="${a.status == 'CANCELADO'}">
                                                <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-red-100 text-red-800">Cancelado</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-gray-100 text-gray-800">${a.status}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </c:if>

        <c:if test="${not empty historicos}">
            <div class="bg-white shadow rounded-lg p-6 mb-6">
                <h2 class="text-xl font-semibold mb-4">Histórico de mudanças</h2>
                <div class="overflow-x-auto">
                    <table class="min-w-full divide-y divide-gray-200">
                        <thead class="bg-gray-50">
                            <tr>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Agendamento</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Sala</th>
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
                                    <td class="px-6 py-4 text-sm">${h.agendamento.sala.nome}</td>
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
                </div>
            </div>
        </c:if>

        <c:if test="${not empty transacoes}">
            <div class="bg-white shadow rounded-lg p-6 mb-6">
                <h2 class="text-xl font-semibold mb-4">Transações confirmadas no período</h2>
                <div class="overflow-x-auto">
                    <table class="min-w-full divide-y divide-gray-200">
                        <thead class="bg-gray-50">
                            <tr>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">ID</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Agendamento</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Tipo</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Cliente</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Valor</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Quando</th>
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
                </div>
                <c:if test="${not empty valorTotal}">
                    <div class="mt-4 bg-green-50 border border-green-200 text-green-800 px-4 py-3 rounded">
                        Total no período: <strong>R$ ${valorTotal}</strong>
                    </div>
                </c:if>
            </div>
        </c:if>

        <div class="mt-6">
            <a href="<c:url value='/recepcionista'/>" 
               class="bg-gray-600 hover:bg-gray-700 text-white px-4 py-2 rounded">
                Voltar
            </a>
        </div>
    </main>
</body>
</html>

