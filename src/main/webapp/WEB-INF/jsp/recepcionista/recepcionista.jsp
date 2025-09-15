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
        <h1 class="text-3xl md:text-4xl font-extrabold mb-2 text-center">Bem-vindo ao Painel do Recepcionista</h1>
        <c:if test="${not empty setor}">
            <p class="text-center text-gray-600 mb-8">Setor atual: <span class="font-semibold">${setor.nome}</span> (ID: ${setor.id})</p>
        </c:if>

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

        <section class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            <div class="bg-white shadow rounded-lg p-6">
                <div class="flex items-center justify-between mb-4">
                    <h3 class="text-xl font-semibold text-gray-900">Gerenciar Agendamentos</h3>
                    <svg class="h-8 w-8 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
                    </svg>
                </div>
                <p class="text-gray-600 mb-4">Visualize e gerencie solicitações de agendamento do seu setor.</p>
                <div class="space-y-2">
                    <a href="<c:url value='/recepcionista/agendamentos?setorId=${setor.id}'/>" class="block w-full bg-blue-600 hover:bg-blue-700 text-white text-center px-4 py-2 rounded text-sm">
                        Ver Agendamentos
                    </a>
                </div>
            </div>

            <div class="bg-white shadow rounded-lg p-6">
                <div class="flex items-center justify-between mb-4">
                    <h3 class="text-xl font-semibold text-gray-900">Agendamento Instantâneo</h3>
                    <svg class="h-8 w-8 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
                    </svg>
                </div>
                <p class="text-gray-600 mb-4">Crie agendamentos diretamente sem solicitação prévia do cliente.</p>
                <div class="space-y-2">
                    <a href="<c:url value='/recepcionista/agendamentos/instantaneo?setorId=${setor.id}'/>" class="block w-full bg-green-600 hover:bg-green-700 text-white text-center px-4 py-2 rounded text-sm">
                        Criar Agendamento
                    </a>
                </div>
            </div>

            <div class="bg-white shadow rounded-lg p-6">
                <div class="flex items-center justify-between mb-4">
                    <h3 class="text-xl font-semibold text-gray-900">Controle do Setor</h3>
                    <svg class="h-8 w-8 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"></path>
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                    </svg>
                </div>
                <p class="text-gray-600 mb-4">Abra ou feche seu setor para receber agendamentos.</p>
                <div class="space-y-2">
                    <a href="<c:url value='/recepcionista/setor/abrir?setorId=${setor.id}'/>" class="block w-full bg-green-600 hover:bg-green-700 text-white text-center px-4 py-2 rounded text-sm">
                        Abrir Setor
                    </a>
                    <a href="<c:url value='/recepcionista/setor/fechar?setorId=${setor.id}'/>" class="block w-full bg-red-600 hover:bg-red-700 text-white text-center px-4 py-2 rounded text-sm">
                        Fechar Setor
                    </a>
                </div>
            </div>

            <!-- Relatórios -->
            <div class="bg-white shadow rounded-lg p-6">
                <div class="flex items-center justify-between mb-4">
                    <h3 class="text-xl font-semibold text-gray-900">Relatórios</h3>
                    <svg class="h-8 w-8 text-orange-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
                    </svg>
                </div>
                <p class="text-gray-600 mb-4">Visualize relatórios e estatísticas do seu setor.</p>
                <div class="space-y-2">
                    <a href="<c:url value='/recepcionista/relatorios?setorId=${setor.id}'/>" class="block w-full bg-orange-600 hover:bg-orange-700 text-white text-center px-4 py-2 rounded text-sm">
                        Ver Relatórios
                    </a>
                </div>
            </div>
        </section>

        <div class="mt-12 bg-white shadow rounded-lg p-6">
            <h2 class="text-2xl font-bold mb-4 text-center">Suas Responsabilidades</h2>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div class="space-y-4">
                    <div class="flex items-start">
                        <div class="bg-blue-100 rounded-full p-2 mr-3 mt-1">
                            <svg class="h-5 w-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                            </svg>
                        </div>
                        <div>
                            <h3 class="font-semibold">Confirmar Agendamentos</h3>
                            <p class="text-gray-600 text-sm">Avalie e confirme solicitações de agendamento dos clientes.</p>
                        </div>
                    </div>
                    <div class="flex items-start">
                        <div class="bg-green-100 rounded-full p-2 mr-3 mt-1">
                            <svg class="h-5 w-5 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
                            </svg>
                        </div>
                        <div>
                            <h3 class="font-semibold">Agendamento Direto</h3>
                            <p class="text-gray-600 text-sm">Crie agendamentos instantâneos para clientes presenciais.</p>
                        </div>
                    </div>
                </div>
                <div class="space-y-4">
                    <div class="flex items-start">
                        <div class="bg-purple-100 rounded-full p-2 mr-3 mt-1">
                            <svg class="h-5 w-5 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v10a2 2 0 002 2h8a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"></path>
                            </svg>
                        </div>
                        <div>
                            <h3 class="font-semibold">Finalizar Uso</h3>
                            <p class="text-gray-600 text-sm">Finalize agendamentos e receba o pagamento restante.</p>
                        </div>
                    </div>
                    <div class="flex items-start">
                        <div class="bg-orange-100 rounded-full p-2 mr-3 mt-1">
                            <svg class="h-5 w-5 text-orange-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
                            </svg>
                        </div>
                        <div>
                            <h3 class="font-semibold">Relatórios</h3>
                            <p class="text-gray-600 text-sm">Acompanhe movimentação de caixa e estatísticas do setor.</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>

      
        <div class="mt-8 bg-blue-50 border border-blue-200 rounded-lg p-6">
            <h3 class="text-lg font-semibold text-blue-800 mb-3">💰 Informações sobre Pagamento</h3>
            <div class="text-blue-700">
                <p class="mb-2">• <strong>Valor por hora:</strong> Calculado automaticamente baseado no tempo de uso</p>
                <p class="mb-2">• <strong>Confirmação:</strong> Cliente paga 50% do valor (sinal)</p>
                <p class="mb-2">• <strong>Finalização:</strong> Cliente paga os 50% restantes</p>
                <p>• <strong>Caixa do Setor:</strong> Valores são creditados automaticamente</p>
            </div>
        </div>
    </main>
</body>
</html>
