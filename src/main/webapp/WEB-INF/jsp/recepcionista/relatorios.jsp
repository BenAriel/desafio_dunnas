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

        <!-- Resumo de Agendamentos -->
        <div class="bg-white shadow rounded-lg p-6 mb-6">
            <h2 class="text-xl font-semibold mb-4">Resumo de Agendamentos</h2>
            <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
                <div class="bg-orange-50 p-4 rounded-lg text-center">
                    <h3 class="text-sm font-medium text-orange-600">Solicitados</h3>
                    <p class="text-2xl font-bold text-orange-900">${solicitados != null ? solicitados.size() : 0}</p>
                </div>
                <div class="bg-blue-50 p-4 rounded-lg text-center">
                    <h3 class="text-sm font-medium text-blue-600">Confirmados</h3>
                    <p class="text-2xl font-bold text-blue-900">${confirmados != null ? confirmados.size() : 0}</p>
                </div>
                <div class="bg-green-50 p-4 rounded-lg text-center">
                    <h3 class="text-sm font-medium text-green-600">Finalizados</h3>
                    <p class="text-2xl font-bold text-green-900">${finalizados != null ? finalizados.size() : 0}</p>
                </div>
                <div class="bg-gray-50 p-4 rounded-lg text-center">
                    <h3 class="text-sm font-medium text-gray-600">Total</h3>
                    <p class="text-2xl font-bold text-gray-900">${(solicitados != null ? solicitados.size() : 0) + (confirmados != null ? confirmados.size() : 0) + (finalizados != null ? finalizados.size() : 0)}</p>
                </div>
            </div>
        </div>

        <!-- Filtros de Relatório -->
        <div class="bg-white shadow rounded-lg p-6 mb-6">
            <h2 class="text-xl font-semibold mb-4">Filtros de Relatório</h2>
            <form method="get" action="<c:url value='/recepcionista/relatorios'/>" class="grid grid-cols-1 md:grid-cols-3 gap-4">
                <input type="hidden" name="setorId" value="${setor.id}" />
                
                <div>
                    <label for="dataInicio" class="block text-sm font-medium text-gray-700 mb-2">Data Início</label>
                    <input type="date" 
                           id="dataInicio" 
                           name="dataInicio" 
                           class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                </div>
                
                <div>
                    <label for="dataFim" class="block text-sm font-medium text-gray-700 mb-2">Data Fim</label>
                    <input type="date" 
                           id="dataFim" 
                           name="dataFim" 
                           class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                </div>
                
                <div class="flex items-end">
                    <button type="submit" 
                            class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded">
                        Filtrar
                    </button>
                </div>
            </form>
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
