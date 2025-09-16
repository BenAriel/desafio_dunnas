<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <title>Relatório Financeiro</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-50 text-gray-900">
    <%@ include file="/WEB-INF/jsp/components/header.jsp" %>
    <main class="max-w-6xl mx-auto p-6">
        <h1 class="text-3xl font-bold mb-6">Relatório Financeiro</h1>
        <p class="text-gray-600 mb-4">Selecione um setor e um período para listar transações confirmadas e o total.</p>

        <c:if test="${not empty error}">
            <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4" data-auto-dismiss="3000">
                ${error}
            </div>
        </c:if>

        <form method="get" class="bg-white p-4 rounded shadow mb-6 grid grid-cols-1 md:grid-cols-4 gap-4">
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Setor</label>
                <select name="setorId" class="w-full border rounded px-3 py-2">
                    <option value="">Selecione</option>
                    <c:forEach var="s" items="${setores}">
                        <option value="${s.id}" ${setorId == s.id ? 'selected' : ''}>${s.nome}</option>
                    </c:forEach>
                </select>
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Data Início</label>
                <input type="date" name="dataInicio" value="${dataInicio}" class="w-full border rounded px-3 py-2"/>
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Data Fim</label>
                <input type="date" name="dataFim" value="${dataFim}" class="w-full border rounded px-3 py-2"/>
            </div>
            <div class="flex items-end">
                <button class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded">Filtrar</button>
            </div>
        </form>

        <c:if test="${not empty transacoes}">
            <div class="bg-white shadow rounded-lg overflow-hidden mb-6">
                <div class="px-6 py-4 border-b font-semibold">Transações confirmadas no período</div>
                <table class="min-w-full divide-y divide-gray-200">
                    <thead class="bg-gray-50">
                        <tr>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">ID</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Agendamento</th>
                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Tipo</th>
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
                                <td class="px-6 py-4 text-sm">R$ ${t.valor}</td>
                                <td class="px-6 py-4 text-sm">${t.dataTransacao}</td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </c:if>

        <c:if test="${not empty valorTotal}">
            <div class="bg-green-50 border border-green-200 text-green-800 px-4 py-3 rounded mb-6">
                Total no período: <strong>R$ ${valorTotal}</strong>
            </div>
        </c:if>

        <div class="mt-8">
            <a href="<c:url value='/admin/relatorios'/>" 
               class="bg-gray-600 hover:bg-gray-700 text-white px-4 py-2 rounded">
                Voltar
            </a>
        </div>
    </main>
</body>
</html>
