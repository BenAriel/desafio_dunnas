<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="pt-br">
  <head>
    <title>Administração</title>
    <script src="https://cdn.tailwindcss.com"></script>
  </head>
  <body class="bg-gray-50 text-gray-900">
    <%@ include file="/WEB-INF/jsp/components/header.jsp" %>
    
      <div class="mb-4">
      <c:if test="${param.error != null}">
          <div class="bg-red-100 text-red-800 p-3 rounded text-center" data-auto-dismiss="3000">${param.error}</div>
        </c:if>
        <c:if test="${param.success != null}">
          <div class="bg-green-100 text-green-800 p-3 rounded text-center" data-auto-dismiss="3000">${param.success}</div>
        </c:if>

        <c:if test="${not empty error}">
          <div class="bg-red-100 text-red-800 p-3 rounded text-center" data-auto-dismiss="3000">${error}</div>
        </c:if>
        <c:if test="${not empty success}">
          <div class="bg-green-100 text-green-800 p-3 rounded text-center" data-auto-dismiss="3000">${success}</div>
        </c:if>

      </div>
    <main class="max-w-6xl mx-auto p-6">
      <h1 class="text-3xl md:text-4xl font-extrabold mb-8 text-center">Bem vindo ao módulo de administrador</h1>

      <section class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <a href="/admin/recepcionistas" class="group block rounded-xl border border-gray-200 bg-white p-8 shadow-sm hover:shadow-md transition-shadow">
          <div class="h-40 flex items-center justify-center text-2xl md:text-3xl font-bold text-blue-700 group-hover:text-blue-800">Recepcionistas</div>
        </a>
        <a href="/admin/setores" class="group block rounded-xl border border-gray-200 bg-white p-8 shadow-sm hover:shadow-md transition-shadow">
          <div class="h-40 flex items-center justify-center text-2xl md:text-3xl font-bold text-green-700 group-hover:text-green-800">Setores</div>
        </a>
        <a href="/admin/salas" class="group block rounded-xl border border-gray-200 bg-white p-8 shadow-sm hover:shadow-md transition-shadow">
          <div class="h-40 flex items-center justify-center text-2xl md:text-3xl font-bold text-purple-700 group-hover:text-purple-800">Salas</div>
        </a>
        <a href="/admin/clientes" class="group block rounded-xl border border-gray-200 bg-white p-8 shadow-sm hover:shadow-md transition-shadow">
          <div class="h-40 flex items-center justify-center text-2xl md:text-3xl font-bold text-orange-700 group-hover:text-orange-800">Clientes</div>
        </a>
        <a href="/admin/administradores" class="group block rounded-xl border border-gray-200 bg-white p-8 shadow-sm hover:shadow-md transition-shadow">
          <div class="h-40 flex items-center justify-center text-2xl md:text-3xl font-bold text-indigo-700 group-hover:text-indigo-800">Administradores</div>
        </a>
        <a href="/admin/relatorios" class="group block rounded-xl border border-gray-200 bg-white p-8 shadow-sm hover:shadow-md transition-shadow">
          <div class="h-40 flex items-center justify-center text-2xl md:text-3xl font-bold text-gray-700 group-hover:text-gray-800">Relatórios</div>
        </a>
      </section>

      <div class="mt-12 flex justify-center">
        <img src="<c:url value='/images/logo.png'/>" alt="Logo" class="h-56 opacity-80" />
      </div>
    </main>
  </body>
</html>
