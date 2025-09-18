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
      <h1 class="text-3xl md:text-4xl font-extrabold mb-8 text-center">Bem vindo ao Painel de administrador</h1>

      <section class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <a href="<c:url value='/admin/recepcionistas'/>" class="group block rounded-xl border border-gray-200 bg-white p-8 shadow-sm hover:shadow-md transition-shadow">
          <div class="h-40 flex items-center justify-center text-2xl md:text-3xl font-bold text-blue-700 group-hover:text-blue-800">
            <div class="text-center">
              <svg class="mx-auto h-12 w-12 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 11V7a4 4 0 00-8 0v4M5 11h14v10a2 2 0 01-2 2H7a2 2 0 01-2-2V11z"/>
              </svg>
              Recepcionistas
            </div>
          </div>
          <p class="text-center text-gray-600 mt-2">Gerenciar equipe de recepção</p>
        </a>
        <a href="<c:url value='/admin/setores'/>" class="group block rounded-xl border border-gray-200 bg-white p-8 shadow-sm hover:shadow-md transition-shadow">
          <div class="h-40 flex items-center justify-center text-2xl md:text-3xl font-bold text-blue-700 group-hover:text-blue-800">
            <div class="text-center">
              <svg class="mx-auto h-12 w-12 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"/>
              </svg>
              Setores
            </div>
          </div>
          <p class="text-center text-gray-600 mt-2">Criar e administrar setores</p>
        </a>
        <a href="<c:url value='/admin/salas'/>" class="group block rounded-xl border border-gray-200 bg-white p-8 shadow-sm hover:shadow-md transition-shadow">
          <div class="h-40 flex items-center justify-center text-2xl md:text-3xl font-bold text-green-700 group-hover:text-green-800">
            <div class="text-center">
              <svg class="mx-auto h-12 w-12 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"/>
              </svg>
              Salas
            </div>
          </div>
          <p class="text-center text-gray-600 mt-2">Gerenciar salas e valores</p>
        </a>
        <a href="<c:url value='/admin/relatorios'/>" class="group block rounded-xl border border-gray-200 bg-white p-8 shadow-sm hover:shadow-md transition-shadow">
          <div class="h-40 flex items-center justify-center text-2xl md:text-3xl font-bold text-purple-700 group-hover:text-purple-800">
            <div class="text-center">
              <svg class="mx-auto h-12 w-12 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2m0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2"/>
              </svg>
              Relatórios
            </div>
          </div>
          <p class="text-center text-gray-600 mt-2">Visão geral e histórico</p>
        </a>
      </section>

      <div class="mt-12 flex justify-center">
        <img src="<c:url value='/images/logo.png'/>" alt="Logo" class="h-56 opacity-80" />
      </div>
    </main>
  </body>
</html>
