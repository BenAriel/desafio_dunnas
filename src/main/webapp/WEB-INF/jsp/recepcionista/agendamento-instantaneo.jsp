<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <title>Agendamento Instantâneo</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-50 text-gray-900">
    <%@ include file="/WEB-INF/jsp/components/header.jsp" %>
    
    <main class="max-w-2xl mx-auto p-6">
        <h1 class="text-3xl font-bold mb-6">Agendamento Instantâneo</h1>

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


       

        <c:if test="${not empty sala}">
        <div class="bg-white shadow rounded-lg p-6 mb-6">
            <h2 class="text-xl font-semibold mb-4">Informações da Sala</h2>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                    <p class="text-sm text-gray-600">Nome da Sala</p>
                    <p class="text-lg font-medium">${sala.nome}</p>
                </div>
                <div>
                    <p class="text-sm text-gray-600">Setor</p>
                    <p class="text-lg font-medium">${sala.setor.nome}</p>
                </div>
                <div>
                    <p class="text-sm text-gray-600">Valor por Hora</p>
                    <p class="text-lg font-medium text-green-600">R$ ${sala.valorPorHora}/hora</p>
                </div>
                <div>
                    <p class="text-sm text-gray-600">Capacidade</p>
                    <p class="text-lg font-medium">${sala.capacidadeMaxima} pessoas</p>
                </div>
            </div>
        </div>
        </c:if>
    <c:if test="${not empty confirmados}">
        <div class="bg-white border rounded-lg p-4 mb-6">
            <h3 class="text-sm font-medium text-gray-800 mb-2">Horários já confirmados nesta sala</h3>
            <table class="min-w-full divide-y divide-gray-200">
                <thead class="bg-gray-50">
                    <tr>
                        <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Início</th>
                        <th class="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Fim</th>
                    </tr>
                </thead>
                <tbody class="bg-white divide-y divide-gray-200">
                    <c:forEach var="c" items="${confirmados}">
                        <tr>
                            <td class="px-4 py-2 text-sm"><span data-datetime="${c.dataHoraInicio}">${c.dataHoraInicio}</span></td>
                            <td class="px-4 py-2 text-sm"><span data-datetime="${c.dataHoraFim}">${c.dataHoraFim}</span></td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
            <p class="text-xs text-gray-500 mt-2">Dica: escolha um intervalo que não conflite com os horários acima.</p>
        </div>
        </c:if>

         <c:if test="${not empty sala}">
        <div id="resumoPreco" class="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-6" data-valor-por-hora="${sala.valorPorHora}">
            <h3 class="text-sm font-medium text-blue-800 mb-2">Resumo de Preço</h3>
            <p class="text-sm text-blue-700">
                Valor por hora: <strong>R$ ${sala.valorPorHora}</strong><br>
                Estimativa: <span id="estimativaResumo" class="font-semibold">Selecione início e fim</span><br>
                 Sinal (50%): <span id="estimativaSinal" class="font-semibold">—</span>  Restante (50%): <span id="estimativaRestante" class="font-semibold">—</span>
            </p>
        </div>
        </c:if>
        <div class="bg-white shadow rounded-lg p-6">
            <form:form modelAttribute="form" action="${pageContext.request.contextPath}/recepcionista/agendamentos/instantaneo" method="post">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                <form:hidden path="setorId" />

                <div class="mb-4">
                    <label for="salaId" class="block text-sm font-medium text-gray-700 mb-2">Sala</label>
                    <form:select id="salaId" path="salaId" cssClass="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                        <form:option value="" label="Selecione uma sala" />
                        <c:forEach var="sala" items="${salas}">
                            <option value="${sala.id}" ${form.salaId == sala.id ? 'selected' : ''}>${sala.nome}</option>
                        </c:forEach>
                    </form:select>
                    <form:errors path="salaId" cssClass="text-red-600 text-sm" />
                </div>

                <div class="mb-4">
                    <label for="clienteId" class="block text-sm font-medium text-gray-700 mb-2">Cliente</label>
                    <form:select id="clienteId" path="clienteId" cssClass="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                        <form:option value="" label="Selecione um cliente" />
                        <c:forEach var="cliente" items="${clientes}">
                            <option value="${cliente.id}" ${form.clienteId == cliente.id ? 'selected' : ''}>${cliente.usuario.nome} - ${cliente.usuario.email}</option>
                        </c:forEach>
                    </form:select>
                    <form:errors path="clienteId" cssClass="text-red-600 text-sm" />
                    <p class="text-xs text-gray-600 mt-2">
                        Cliente não possui conta? 
                        <a href="<c:url value='/registrar'/>" class="text-blue-600 hover:underline">Crie a conta do cliente</a>.
                    </p>
                </div>

                <div class="mb-4">
                    <label for="dataHoraInicio" class="block text-sm font-medium text-gray-700 mb-2">Data e Hora de Início</label>
                    <form:input type="datetime-local" id="dataHoraInicio" path="dataHoraInicio" step="60" min="${minDateTime}" cssClass="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" />
                    <form:errors path="dataHoraInicio" cssClass="text-red-600 text-sm" />
                    <p class="text-xs text-gray-500 mt-1">Você pode selecionar horas e minutos.</p>
                </div>

                <div class="mb-4">
                    <label for="dataHoraFim" class="block text-sm font-medium text-gray-700 mb-2">Data e Hora de Fim</label>
                    <form:input type="datetime-local" id="dataHoraFim" path="dataHoraFim" step="60" min="${minDateTime}" cssClass="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" />
                    <form:errors path="dataHoraFim" cssClass="text-red-600 text-sm" />
                    <p class="text-xs text-gray-500 mt-1">Você pode selecionar horas e minutos.</p>
                </div>

                <div class="mb-6">
                    <label for="observacoes" class="block text-sm font-medium text-gray-700 mb-2">Observações (opcional)</label>
                    <form:textarea id="observacoes" path="observacoes" rows="3" cssClass="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" />
                </div>

                <div class="flex gap-3 justify-between">
                    <button type="submit" 
                            class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded">    Criar e Confirmar Agendamento
                    </button>
                    <a href="<c:url value='/recepcionista/agendamentos?setorId=${setorId}'/>" 
                       class="bg-gray-600 hover:bg-gray-700 text-white px-4 py-2 rounded">
                        Cancelar
                    </a>
                </div>
            </form:form>
        </div>
        
    </main>

    <script defer src="<c:url value='/js/recepcionista/agendamento-instantaneo.js'/>"></script>
</body>
</html>
