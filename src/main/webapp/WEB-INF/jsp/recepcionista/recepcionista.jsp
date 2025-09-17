<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <title>Dashboard Recepcionista</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-50 text-gray-900">
    <%@ include file="/WEB-INF/jsp/components/header.jsp" %>
    
    <main class="max-w-6xl mx-auto p-6">
        <h1 class="text-3xl md:text-4xl font-extrabold mb-8 text-center">Bem-vindo ao Sistema de Reservas</h1>
        <c:if test="${not empty success}">
            <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded mb-6 text-center" data-auto-dismiss="3000">
                ${success}
            </div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-6 text-center" data-auto-dismiss="3000">
                ${error}
            </div>
        </c:if>

        <c:if test="${not empty setor}">
            <div class="bg-white shadow rounded-lg p-6 mb-8">
                <h2 class="text-xl font-semibold mb-4">Informações do Setor</h2>
                <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                    <div class="bg-blue-50 p-4 rounded-lg">
                        <h3 class="text-sm font-medium text-blue-600">Nome do Setor</h3>
                        <p class="text-2xl font-bold text-blue-900">${setor.nome}</p>
                    </div>
                    <div class="bg-green-50 p-4 rounded-lg">
                        <h3 class="text-sm font-medium text-green-600">Valor em Caixa</h3>
                        <p class="text-2xl font-bold text-green-900">R$ <span id="valor-caixa-home">${setor.caixa}</span></p>
                    </div>
                    <div class="bg-purple-50 p-4 rounded-lg">
                        <h3 class="text-sm font-medium text-purple-600">Status</h3>
                        <p class="text-2xl font-bold text-purple-900"><span id="status-setor">${setor.aberto ? 'Aberto' : 'Fechado'}</span></p>
                    </div>
                </div>
                <div class="mt-4">
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
        </c:if>

        <section class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            <a href="<c:url value='/recepcionista/agendamentos?setorId=${setor.id}'/>" class="group block rounded-xl border border-gray-200 bg-white p-8 shadow-sm hover:shadow-md transition-shadow">
                <div class="h-40 flex items-center justify-center text-2xl md:text-3xl font-bold text-blue-700 group-hover:text-blue-800">
                    <div class="text-center">
                        <svg class="mx-auto h-12 w-12 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/>
                        </svg>
                        Agendamentos
                    </div>
                </div>
                <p class="text-center text-gray-600 mt-2">Gerenciar solicitações e reservas</p>
            </a>

            <a href="<c:url value='/recepcionista/agendamentos/instantaneo?setorId=${setor.id}'/>" class="group block rounded-xl border border-gray-200 bg-white p-8 shadow-sm hover:shadow-md transition-shadow">
                <div class="h-40 flex items-center justify-center text-2xl md:text-3xl font-bold text-green-700 group-hover:text-green-800">
                    <div class="text-center">
                        <svg class="mx-auto h-12 w-12 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"/>
                        </svg>
                        Agendamento Instantâneo
                    </div>
                </div>
                <p class="text-center text-gray-600 mt-2">Criar reservas diretas no balcão</p>
            </a>

            <a href="<c:url value='/recepcionista/relatorios?setorId=${setor.id}'/>" class="group block rounded-xl border border-gray-200 bg-white p-8 shadow-sm hover:shadow-md transition-shadow">
                <div class="h-40 flex items-center justify-center text-2xl md:text-3xl font-bold text-purple-700 group-hover:text-purple-800">
                    <div class="text-center">
                        <svg class="mx-auto h-12 w-12 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2m0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2"/>
                        </svg>
                        Relatórios
                    </div>
                </div>
                <p class="text-center text-gray-600 mt-2">Estatísticas e movimentações</p>
            </a>
        </section>

        <div class="mt-12 flex justify-center">
            <img src="<c:url value='/images/logo.png'/>" alt="Logo" class="h-56 opacity-80" />
        </div>
    </main>
</body>
</html>
