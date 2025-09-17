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

        <div class="bg-white shadow rounded-lg p-4 mb-6">
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div class="bg-blue-50 p-4 rounded-lg">
                    <h3 class="text-sm font-medium text-blue-600">Setor</h3>
                    <p class="text-lg font-bold text-blue-900">
                        <c:choose>
                            <c:when test="${not empty setor}">${setor.nome}</c:when>
                            <c:otherwise>ID: ${setorId}</c:otherwise>
                        </c:choose>
                    </p>
                </div>
                <div class="bg-green-50 p-4 rounded-lg">
                    <h3 class="text-sm font-medium text-green-600">Valor em Caixa</h3>
                    <p class="text-2xl font-bold text-green-900">R$ 
                        <span id="valor-caixa-agds">
                            <c:choose>
                                <c:when test="${not empty setor}">${setor.caixa}</c:when>
                                <c:otherwise>...</c:otherwise>
                            </c:choose>
                        </span>
                    </p>
                </div>
                <div class="bg-purple-50 p-4 rounded-lg">
                    <h3 class="text-sm font-medium text-purple-600">Status</h3>
                    <p class="text-2xl font-bold text-purple-900"><span id="status-setor-agds">
                        <c:choose>
                            <c:when test="${not empty setor and setor.aberto}">Aberto</c:when>
                            <c:when test="${not empty setor}">Fechado</c:when>
                            <c:otherwise>...</c:otherwise>
                        </c:choose>
                    </span></p>
                </div>
            </div>
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
                                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">${agendamento.cliente.usuario.nome}</td>
                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">${agendamento.sala.nome}</td>
                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900"><span data-datetime="${agendamento.dataHoraInicio}">${agendamento.dataHoraInicio}</span></td>
                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900"><span data-datetime="${agendamento.dataHoraFim}">${agendamento.dataHoraFim}</span></td>
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
                                    <form action="<c:url value='/recepcionista/agendamentos/cancelar'/>" method="post" class="inline ml-2">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                        <input type="hidden" name="agendamentoId" value="${agendamento.id}" />
                                        <input type="hidden" name="setorId" value="${setorId}" />
                                        <button type="submit" 
                                                class="bg-red-600 hover:bg-red-700 text-white px-3 py-1 rounded text-sm"
                                                onclick="return confirm('Tem certeza que deseja cancelar esta solicitação?')">
                                            Cancelar
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
                                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">${agendamento.cliente.usuario.nome}</td>
                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">${agendamento.sala.nome}</td>
                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900"><span data-datetime="${agendamento.dataHoraInicio}">${agendamento.dataHoraInicio}</span></td>
                                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900"><span data-datetime="${agendamento.dataHoraFim}">${agendamento.dataHoraFim}</span></td>
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
                                    <form action="<c:url value='/recepcionista/agendamentos/cancelar'/>" method="post" class="inline ml-2 cancel-confirmado" data-inicio="${agendamento.dataHoraInicio}">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                        <input type="hidden" name="agendamentoId" value="${agendamento.id}" />
                                        <input type="hidden" name="setorId" value="${setorId}" />
                                        <button type="submit" 
                                                class="bg-red-600 hover:bg-red-700 text-white px-3 py-1 rounded text-sm"
                                                onclick="return confirm('Tem certeza que deseja cancelar este agendamento confirmado? O valor de sinal será estornado do caixa.')">
                                            Cancelar
                                        </button>
                                    </form>
                                </td>
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
    <script>
        // Oculta botões de cancelar para agendamentos cujo horário de início já passou
        (function() {
            try {
                var agora = new Date();
                document.querySelectorAll('.cancel-confirmado').forEach(function(el) {
                    var v = el.getAttribute('data-inicio');
                    if (!v) { return; }
                    var inicio = new Date(v);
                    if (isNaN(inicio.getTime())) {
                       
                        inicio = new Date(v.replace(' ', 'T'));
                    }
                    if (inicio <= agora) {
                        el.style.display = 'none';
                    }
                });
               
                document.querySelectorAll('[data-datetime]').forEach(function(span){
                    var raw = span.getAttribute('data-datetime');
                    var d = new Date(raw);
                    if (isNaN(d.getTime())) { d = new Date(raw.replace(' ', 'T')); }
                    if (!isNaN(d.getTime())) {
                        var fmt = d.toLocaleString('pt-BR', { year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit' });
                        span.textContent = fmt;
                    }
                });
                document.querySelectorAll('[data-auto-dismiss]')
                    .forEach(function(el){
                        var ms = parseInt(el.getAttribute('data-auto-dismiss')) || 3000;
                        setTimeout(function(){ el.style.display = 'none'; }, ms);
                    });
            } catch (e) {  }
        })();

       
    </script>
</body>
</html>

