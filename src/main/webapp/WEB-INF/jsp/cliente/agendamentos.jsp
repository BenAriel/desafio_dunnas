<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <title>Meus Agendamentos</title>
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
                                                    onclick="return confirm('Tem certeza que deseja cancelar este agendamento?')">
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
                                                    onclick="return confirm('Deseja cancelar este agendamento confirmado? O valor de sinal será estornado do caixa.')">
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
    <script>
        // Oculta o botão de cancelamento para confirmados cujo início já passou
        (function(){
            try {
                var agora = new Date();
                document.querySelectorAll('.cancel-confirmado').forEach(function(el){
                    var raw = el.getAttribute('data-inicio');
                    if (!raw) return;
                    var d = new Date(raw);
                    if (isNaN(d.getTime())) { d = new Date(raw.replace(' ', 'T')); }
                    if (!isNaN(d.getTime()) && d <= agora) {
                        el.style.display = 'none';
                    }
                });
               
                document.querySelectorAll('[data-datetime]').forEach(function(span){
                    var raw = span.getAttribute('data-datetime');
                    var d = new Date(raw);
                    if (isNaN(d.getTime())) { d = new Date(raw.replace(' ', 'T')); }
                    if (!isNaN(d.getTime())) {
                        span.textContent = d.toLocaleString('pt-BR', {year:'numeric', month:'2-digit', day:'2-digit', hour:'2-digit', minute:'2-digit'});
                    }
                });
               
                document.querySelectorAll('[data-auto-dismiss]')
                    .forEach(function(el){
                        var ms = parseInt(el.getAttribute('data-auto-dismiss')) || 3000;
                        setTimeout(function(){ el.style.display = 'none'; }, ms);
                    });
            } catch(e) {}
        })();
    </script>
</body>
</html>
