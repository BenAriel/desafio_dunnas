<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <title>Dashboard Cliente</title>
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
        

        <section class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            <a href="<c:url value='/cliente/setores'/>" class="group block rounded-xl border border-gray-200 bg-white p-8 shadow-sm hover:shadow-md transition-shadow">
                <div class="h-40 flex items-center justify-center text-2xl md:text-3xl font-bold text-blue-700 group-hover:text-blue-800">
                    <div class="text-center">
                        <svg class="mx-auto h-12 w-12 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"></path>
                        </svg>
                        Setores
                    </div>
                </div>
                <p class="text-center text-gray-600 mt-2">Visualizar setores disponíveis</p>
            </a>

            <a href="<c:url value='/cliente/salas'/>" class="group block rounded-xl border border-gray-200 bg-white p-8 shadow-sm hover:shadow-md transition-shadow">
                <div class="h-40 flex items-center justify-center text-2xl md:text-3xl font-bold text-green-700 group-hover:text-green-800">
                    <div class="text-center">
                        <svg class="mx-auto h-12 w-12 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"></path>
                        </svg>
                        Salas
                    </div>
                </div>
                <p class="text-center text-gray-600 mt-2">Ver salas disponíveis e valores</p>
            </a>

                <a href="<c:url value='/cliente/agendamentos'/>" class="group block rounded-xl border border-gray-200 bg-white p-8 shadow-sm hover:shadow-md transition-shadow">
                <div class="h-40 flex items-center justify-center text-2xl md:text-3xl font-bold text-purple-700 group-hover:text-purple-800">
                    <div class="text-center">
                        <svg class="mx-auto h-12 w-12 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
                        </svg>
                        Meus Agendamentos
                    </div>
                </div>
                <p class="text-center text-gray-600 mt-2">Gerenciar suas reservas</p>
            </a>
        </section>

        <div class="mt-12 bg-white shadow rounded-lg p-6">
            <h2 class="text-2xl font-bold mb-4 text-center">Como Funciona</h2>
            <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div class="text-center">
                    <div class="bg-blue-100 rounded-full p-3 w-16 h-16 mx-auto mb-4 flex items-center justify-center">
                        <span class="text-2xl font-bold text-blue-600">1</span>
                    </div>
                    <h3 class="font-semibold mb-2">Escolha uma Sala</h3>
                    <p class="text-gray-600 text-sm">Navegue pelos setores e escolha a sala que melhor atende suas necessidades.</p>
                </div>
                <div class="text-center">
                    <div class="bg-green-100 rounded-full p-3 w-16 h-16 mx-auto mb-4 flex items-center justify-center">
                        <span class="text-2xl font-bold text-green-600">2</span>
                    </div>
                    <h3 class="font-semibold mb-2">Solicite o Agendamento</h3>
                    <p class="text-gray-600 text-sm">Preencha o formulário com data, horário e suas informações.</p>
                </div>
                <div class="text-center">
                    <div class="bg-purple-100 rounded-full p-3 w-16 h-16 mx-auto mb-4 flex items-center justify-center">
                        <span class="text-2xl font-bold text-purple-600">3</span>
                    </div>
                    <h3 class="font-semibold mb-2">Aguarde Confirmação</h3>
                    <p class="text-gray-600 text-sm">O recepcionista confirmará sua solicitação e você pagará 50% do valor.</p>
                </div>
            </div>
        </div>

        <div class="mt-8 bg-blue-50 border border-blue-200 rounded-lg p-6">
            <h3 class="text-lg font-semibold text-blue-800 mb-3">💡 Informações sobre Pagamento</h3>
            <div class="text-blue-700">
                <p class="mb-2">• <strong>Valor por hora:</strong> Calculado automaticamente baseado no tempo de uso</p>
                <p class="mb-2">• <strong>Sinal (50%):</strong> Pago na confirmação do agendamento</p>
                <p class="mb-2">• <strong>Restante (50%):</strong> Pago na finalização do uso da sala</p>
                <p>• <strong>Cancelamento:</strong> Possível apenas antes da confirmação</p>
            </div>
        </div>
    </main>
</body>
</html>
