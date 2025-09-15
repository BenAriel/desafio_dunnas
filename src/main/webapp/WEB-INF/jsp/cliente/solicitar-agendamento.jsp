<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <title>Solicitar Agendamento</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-50 text-gray-900">
    <%@ include file="/WEB-INF/jsp/components/header.jsp" %>
    
    <main class="max-w-2xl mx-auto p-6">
        <h1 class="text-3xl font-bold mb-6">Solicitar Agendamento</h1>

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
        <div class="bg-white shadow rounded-lg p-6">
            <form:form modelAttribute="form" action="${pageContext.request.contextPath}/cliente/agendamentos/solicitar" method="post">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                <form:hidden path="salaId" />


                <div class="mb-4">
                    <label for="dataHoraInicio" class="block text-sm font-medium text-gray-700 mb-2">Data e Hora de Início</label>
              <form:input type="datetime-local" 
                  id="dataHoraInicio" 
                  path="dataHoraInicio" 
                           step="3600"
                  cssClass="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"/>
              <form:errors path="dataHoraInicio" cssClass="text-red-600 text-sm" />
                    <p class="text-xs text-gray-500 mt-1">Selecione apenas a hora (sem minutos) para facilitar o agendamento.</p>
                </div>

                <div class="mb-4">
                    <label for="dataHoraFim" class="block text-sm font-medium text-gray-700 mb-2">Data e Hora de Fim</label>
              <form:input type="datetime-local" 
                  id="dataHoraFim" 
                  path="dataHoraFim" 
                           step="3600"
                  cssClass="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"/>
              <form:errors path="dataHoraFim" cssClass="text-red-600 text-sm" />
                    <p class="text-xs text-gray-500 mt-1">Selecione apenas a hora (sem minutos) para facilitar o agendamento.</p>
                </div>

                <div class="mb-6">
                    <label for="observacoes" class="block text-sm font-medium text-gray-700 mb-2">Observações (opcional)</label>
                    <form:textarea id="observacoes" 
                              path="observacoes" 
                              rows="3"
                              placeholder="Informações adicionais sobre o agendamento..."
                              cssClass="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"/>
                </div>

                <!-- Informações sobre Pagamento -->
                <div class="bg-blue-50 p-4 rounded-lg mb-6">
                    <h3 class="text-sm font-medium text-blue-800 mb-2">Informações sobre Pagamento</h3>
                    <p class="text-sm text-blue-700">
                        • Valor por hora: <strong>R$ ${sala.valorPorHora}</strong><br>
                        • Valor total: <strong>Calculado automaticamente</strong> (valor/hora × número de horas)<br>
                        • Sinal (50%): <strong>Pago na confirmação</strong><br>
                        • Restante (50%): <strong>Pago na finalização</strong>
                    </p>
                </div>

                <div class="flex gap-3">
                    <button type="submit" 
                            class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded">
                        Solicitar Agendamento
                    </button>
                    <a href="<c:url value='/cliente/salas'/>" 
                       class="bg-gray-600 hover:bg-gray-700 text-white px-4 py-2 rounded">
                        Cancelar
                    </a>
                </div>
            </form:form>
        </div>
    </main>
</body>
</html>
