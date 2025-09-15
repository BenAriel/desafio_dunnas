<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <title>${form.id != null ? 'Editar' : 'Nova'} Sala</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-50 text-gray-900">
    <%@ include file="/WEB-INF/jsp/components/header.jsp" %>
    
    <main class="max-w-2xl mx-auto p-6">
    <h1 class="text-3xl font-bold mb-6">${form.id != null ? 'Editar' : 'Nova'} Sala</h1>

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

        <div class="bg-white shadow rounded-lg p-6">
            <form:form modelAttribute="form" action="${pageContext.request.contextPath}/admin/salas/salvar" method="post">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                <form:hidden path="id" />

                <div class="mb-4">
                    <label for="nome" class="block text-sm font-medium text-gray-700 mb-2">Nome da Sala</label>
                    <form:input path="nome" id="nome" cssClass="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" />
                    <form:errors path="nome" cssClass="text-red-600 text-sm" />
                </div>

                <div class="mb-4">
                    <label for="setorId" class="block text-sm font-medium text-gray-700 mb-2">Setor</label>
                    <form:select path="setorId" id="setorId" cssClass="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                        <form:option value="" label="Selecione um setor" />
                        <c:forEach var="setor" items="${setores}">
                            <option value="${setor.id}" ${form.setorId == setor.id ? 'selected' : ''}>${setor.nome}</option>
                        </c:forEach>
                    </form:select>
                    <form:errors path="setorId" cssClass="text-red-600 text-sm" />
                </div>

                <div class="mb-4">
                    <label for="valorPorHora" class="block text-sm font-medium text-gray-700 mb-2">Valor por Hora (R$)</label>
                    <form:input path="valorPorHora" id="valorPorHora" type="number" step="0.01" min="0" cssClass="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" />
                    <form:errors path="valorPorHora" cssClass="text-red-600 text-sm" />
                    <p class="text-xs text-gray-500 mt-1">O valor será calculado automaticamente baseado no número de horas do agendamento.</p>
                </div>

                <div class="mb-4">
                    <label for="capacidadeMaxima" class="block text-sm font-medium text-gray-700 mb-2">Capacidade Máxima</label>
                    <form:input path="capacidadeMaxima" id="capacidadeMaxima" type="number" min="1" cssClass="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" />
                    <form:errors path="capacidadeMaxima" cssClass="text-red-600 text-sm" />
                </div>

                <div class="mb-6">
                    <label class="flex items-center">
                        <form:checkbox path="ativa" />
                        <span class="ml-2 text-sm text-gray-700">Sala Ativa</span>
                    </label>
                </div>

                <div class="flex gap-3">
                    <button type="submit" 
                            class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded">
                        ${form.id != null ? 'Atualizar' : 'Criar'}
                    </button>
                    <a href="<c:url value='/admin/salas'/>" 
                       class="bg-gray-600 hover:bg-gray-700 text-white px-4 py-2 rounded">
                        Cancelar
                    </a>
                </div>
            </form:form>
        </div>
    </main>
</body>
</html>
