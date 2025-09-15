<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>


<header class="w-full bg-white border-b border-gray-200">
	<div class=" mx-auto px-4 py-3 flex items-center justify-between">
		
		<form action="<c:url value='/logout'/>" method="post" class="m-0">
			<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
			<button type="submit" class="inline-flex items-center gap-2 bg-red-600 hover:bg-red-700 text-white text-sm font-medium px-4 py-2 rounded">
				Sair
			</button>
		</form>

	
		<div class="flex items-center gap-4">
			<div class="text-sm text-gray-700">
				Olá,
				<strong>
					<sec:authorize access="isAuthenticated()">
						<sec:authentication property="principal.nome" />
					</sec:authorize>
				</strong>
								<sec:authorize access="isAuthenticated()">
									<sec:authentication property="authorities" var="auths" />
									<c:set var="roleKey" value="${fn:replace(fn:replace(auths, '[', ''), ']', '')}" />
									<span class="text-gray-500">
										<c:choose>
											<c:when test="${roleKey == 'ROLE_ADMIN'}">(Administrador)</c:when>
											<c:when test="${roleKey == 'ROLE_RECEPCIONISTA'}">(Recepcionista)</c:when>
											<c:when test="${roleKey == 'ROLE_CLIENTE'}">(Cliente)</c:when>
											<c:otherwise>(${roleKey})</c:otherwise>
										</c:choose>
									</span>
								</sec:authorize>
			</div>
		</div>
	</div>
</header>

<script>
	(function () {
		function hideAfterTimeout(el, timeout) {
			setTimeout(function () {
				try {
					el.style.transition = 'opacity 200ms ease';
					el.style.opacity = '0';
					setTimeout(function(){ el.remove(); }, 220);
				} catch (_) {}
			}, timeout);
		}
		document.addEventListener('DOMContentLoaded', function(){
			var nodes = document.querySelectorAll('[data-auto-dismiss]');
			nodes.forEach(function(n){
				var t = parseInt(n.getAttribute('data-auto-dismiss'), 10);
				if (!isNaN(t) && t > 0) hideAfterTimeout(n, t);
			});
		});
	})();
</script>


