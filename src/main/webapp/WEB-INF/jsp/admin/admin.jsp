<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="pt-br">
  <head>
    <title>Administração</title>
    <script src="https://cdn.tailwindcss.com"></script>
  </head>
  <body class="bg-gray-50 text-gray-900">
    <div class="max-w-2xl mx-auto p-6">
      <h1 class="text-3xl font-bold mb-4">Bem-vindo administrador!</h1>

      <div class="grid grid-cols-3 gap-4">
        <a
          href="/usuarios"
          class="bg-blue-600 text-white py-2 px-4 rounded text-center hover:bg-blue-700"
          >Gerenciar Usuários</a
        >
        <a
          href="/cargos"
          class="bg-green-600 text-white py-2 px-4 rounded text-center hover:bg-green-700"
          >Gerenciar Cargos</a
        >
        <a
          href="/setores"
          class="bg-purple-600 text-white py-2 px-4 rounded text-center hover:bg-purple-700"
          >Gerenciar Setores</a
        >
      </div>

   
    </div>
  </body>
</html>
