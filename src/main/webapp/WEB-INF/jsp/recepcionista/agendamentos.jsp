<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <title>Gerenciar Agendamentos</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-50 text-gray-900">
    <%@ include file="/WEB-INF/jsp/components/header.jsp" %>
    
    <main class="max-w-6xl mx-auto p-6">
        <div class="flex justify-between items-center mb-6">
            <h1 class="text-3xl font-bold">Gerenciar Agendamentos</h1>
            <a href="<c:url value='/recepcionista/agendamentos/instantaneo?setorId=${setorId}'/>" 
               class="bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded">
                Agendamento Instantâneo
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

        <div class="mb-8">
            <h2 class="text-2xl font-semibold mb-4 text-orange-600">Solicitações Pendentes</h2>
            <div class="bg-white shadow rounded-lg overflow-hidden">
                <table class="min-w-full divide-y divide-gray-200">
                    <thead class="bg-orange-50">
                        <tr>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">ID</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Cliente</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Sala</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Data/Hora Início</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Data/Hora Fim</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Ações</th>
                        </tr>
                    </thead>
                    <tbody class="bg-white divide-y divide-gray-200">
                        <c:forEach var="agendamento" items="${solicitados}">
                            <tr>
                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">${agendamento.id}</td>
                                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">${agendamento.cliente.nome}</td>
                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">${agendamento.sala.nome}</td>
                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">${agendamento.dataHoraInicio}</td>
                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">${agendamento.dataHoraFim}</td>
                                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                                    <form action="<c:url value='/recepcionista/agendamentos/confirmar'/>" method="post" class="inline">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                        <input type="hidden" name="agendamentoId" value="${agendamento.id}" />
                                        <input type="hidden" name="setorId" value="${setorId}" />
                                        <button type="submit" 
                                                class="bg-green-600 hover:bg-green-700 text-white px-3 py-1 rounded text-sm">
                                            Confirmar
                                        </button>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>

     
        <div class="mb-8">
            <h2 class="text-2xl font-semibold mb-4 text-blue-600">Agendamentos Confirmados</h2>
            <div class="bg-white shadow rounded-lg overflow-hidden">
                <table class="min-w-full divide-y divide-gray-200">
                    <thead class="bg-blue-50">
                        <tr>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">ID</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Cliente</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Sala</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Data/Hora Início</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Data/Hora Fim</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Ações</th>
                        </tr>
                    </thead>
                    <tbody class="bg-white divide-y divide-gray-200">
                        <c:forEach var="agendamento" items="${confirmados}">
                            <tr>
                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">${agendamento.id}</td>
                                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">${agendamento.cliente.nome}</td>
                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">${agendamento.sala.nome}</td>
                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">${agendamento.dataHoraInicio}</td>
                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">${agendamento.dataHoraFim}</td>
                                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                                    <form action="<c:url value='/recepcionista/agendamentos/finalizar'/>" method="post" class="inline">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                        <input type="hidden" name="agendamentoId" value="${agendamento.id}" />
                                        <input type="hidden" name="setorId" value="${setorId}" />
                                        <button type="submit" 
                                                class="bg-blue-600 hover:bg-blue-700 text-white px-3 py-1 rounded text-sm">
                                            Finalizar
                                        </button>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>

  
        <div class="mb-8">
            <h2 class="text-2xl font-semibold mb-4 text-gray-600">Agendamentos Finalizados</h2>
            <div class="bg-white shadow rounded-lg overflow-hidden">
                <table class="min-w-full divide-y divide-gray-200">
                    <thead class="bg-gray-50">
                        <tr>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">ID</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Cliente</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Sala</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Data/Hora Início</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Data/Hora Fim</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Valor Total</th>
                        </tr>
                    </thead>
                    <tbody class="bg-white divide-y divide-gray-200">
                        <c:forEach var="agendamento" items="${finalizados}">
                            <tr>
                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">${agendamento.id}</td>
                                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">${agendamento.cliente.nome}</td>
                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">${agendamento.sala.nome}</td>
                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">${agendamento.dataHoraInicio}</td>
                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">${agendamento.dataHoraFim}</td>
                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">R$ ${agendamento.valorTotal}</td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="mt-6">
            <a href="<c:url value='/recepcionista'/>" 
               class="bg-gray-600 hover:bg-gray-700 text-white px-4 py-2 rounded">
                Voltar
            </a>
        </div>
    </main>
</body>
</html>
