<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <title>Verificar Disponibilidade</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-50 text-gray-900">
    <%@ include file="/WEB-INF/jsp/components/header.jsp" %>
    
    <main class="max-w-4xl mx-auto p-6">
        <h1 class="text-3xl font-bold mb-6">Verificar Disponibilidade</h1>

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

        <div class="bg-white shadow rounded-lg p-6 mb-6">
            <h2 class="text-xl font-semibold mb-4">Período Verificado</h2>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                    <p class="text-sm text-gray-600">Data/Hora Início</p>
                    <p class="text-lg font-medium">${dataInicio}</p>
                </div>
                <div>
                    <p class="text-sm text-gray-600">Data/Hora Fim</p>
                    <p class="text-lg font-medium">${dataFim}</p>
                </div>
            </div>
        </div>

        <div class="bg-white shadow rounded-lg p-6 mb-6">
            <h2 class="text-xl font-semibold mb-4">Resultado da Verificação</h2>
            <c:choose>
                <c:when test="${disponivel}">
                    <div class="bg-green-50 border border-green-200 rounded-lg p-4">
                        <div class="flex items-center">
                            <div class="flex-shrink-0">
                                <svg class="h-5 w-5 text-green-400" viewBox="0 0 20 20" fill="currentColor">
                                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
                                </svg>
                            </div>
                            <div class="ml-3">
                                <h3 class="text-sm font-medium text-green-800">Sala Disponível</h3>
                                <p class="text-sm text-green-700">A sala está disponível no período solicitado.</p>
                            </div>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="bg-red-50 border border-red-200 rounded-lg p-4">
                        <div class="flex items-center">
                            <div class="flex-shrink-0">
                                <svg class="h-5 w-5 text-red-400" viewBox="0 0 20 20" fill="currentColor">
                                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
                                </svg>
                            </div>
                            <div class="ml-3">
                                <h3 class="text-sm font-medium text-red-800">Sala Indisponível</h3>
                                <p class="text-sm text-red-700">A sala não está disponível no período solicitado.</p>
                            </div>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <c:if test="${not empty conflitos}">
            <div class="bg-white shadow rounded-lg p-6 mb-6">
                <h2 class="text-xl font-semibold mb-4">Agendamentos Conflitantes</h2>
                <div class="overflow-x-auto">
                    <table class="min-w-full divide-y divide-gray-200">
                        <thead class="bg-gray-50">
                            <tr>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">ID</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Cliente</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Data/Hora Início</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Data/Hora Fim</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                            </tr>
                        </thead>
                        <tbody class="bg-white divide-y divide-gray-200">
                            <c:forEach var="conflito" items="${conflitos}">
                                <tr>
                                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">${conflito.id}</td>
                                    <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">${conflito.cliente.nome}</td>
                                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">${conflito.dataHoraInicio}</td>
                                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">${conflito.dataHoraFim}</td>
                                    <td class="px-6 py-4 whitespace-nowrap">
                                        <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-blue-100 text-blue-800">
                                            ${conflito.status}
                                        </span>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </c:if>

        <div class="flex gap-3">
            <c:if test="${disponivel}">
                <a href="<c:url value='/cliente/agendamentos/solicitar?salaId=${sala.id}'/>" 
                   class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded">
                    Solicitar Agendamento
                </a>
            </c:if>
            <a href="<c:url value='/cliente/salas'/>" 
               class="bg-gray-600 hover:bg-gray-700 text-white px-4 py-2 rounded">
                Voltar para Salas
            </a>
        </div>
    </main>
</body>
</html>
