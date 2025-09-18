<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <title>${form.id != null ? 'Editar' : 'Novo'} Setor</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-50 text-gray-900">
    <%@ include file="/WEB-INF/jsp/components/header.jsp" %>
    
    <main class="max-w-2xl mx-auto p-6">
    <h1 class="text-3xl font-bold mb-6">${form.id != null ? 'Editar' : 'Novo'} Setor</h1>

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
            <form:form modelAttribute="form" action="${pageContext.request.contextPath}/admin/setores/salvar" method="post">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                <form:hidden path="id" />

                <div class="mb-4">
                    <label for="nome" class="block text-sm font-medium text-gray-700 mb-2">Nome do Setor</label>
                    <form:input path="nome" id="nome" cssClass="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" />
                    <form:errors path="nome" cssClass="text-red-600 text-sm" />
                </div>

                <div class="mb-4">
                    <label for="caixa" class="block text-sm font-medium text-gray-700 mb-2">Valor em Caixa</label>
                    <form:input path="caixa" id="caixa" type="number" step="0.01" min="0" cssClass="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500" />
                    <form:errors path="caixa" cssClass="text-red-600 text-sm" />
                </div>

                <div class="mb-6">
                    <c:choose>
                        <c:when test="${not empty form.id}">
                            <label class="flex items-center">
                                <form:checkbox path="aberto" />
                                <span class="ml-2 text-sm text-gray-700">Setor Aberto</span>
                            </label>
                            <form:errors path="aberto" cssClass="text-red-600 text-sm" />
                        </c:when>
                        <c:otherwise>
                            <p class="text-sm text-gray-500">O Setor só pode ser aberto com um recepcionista alocado.</p>
                        </c:otherwise>
                    </c:choose>
                </div>

                <div class="flex gap-3 justify-between">
                    <button type="submit" 
                            class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded">
                        ${form.id != null ? 'Atualizar' : 'Criar'}
                    </button>
                    <a href="<c:url value='/admin/setores'/>" 
                       class="bg-gray-600 hover:bg-gray-700 text-white px-4 py-2 rounded">
                        Cancelar
                    </a>
                </div>
            </form:form>
        </div>
    </main>
</body>
</html>

