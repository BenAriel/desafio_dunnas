package com.example.desafio_dunnas.config;

import java.sql.SQLException;
import java.util.Locale;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.support.SQLErrorCodeSQLExceptionTranslator;

public final class DbErrorMessageResolver {

    private static final Pattern GENERIC_RAISE_MSG = Pattern.compile("^(.+)$");

    private static final Map<String, String> CONSTRAINT_MESSAGES = Map.of(
            "ux_recepcionista_setor", "Este setor já possui um recepcionista alocado.",
            "tb_usuarios_email_key", "Este e-mail já está cadastrado.",
            "tb_administradores_matricula_key", "Esta matrícula já está cadastrada.",
            "tb_recepcionistas_matricula_key", "Esta matrícula já está cadastrada.",
            "tb_recepcionistas_cpf_key", "Este CPF já está cadastrado.",
            "tb_clientes_telefone_key", "Este telefone já está cadastrado.",
            "ux_sala_nome_setor", "Já existe uma sala com este nome neste setor.");

    private DbErrorMessageResolver() {
    }

    public static String resolve(Throwable t) {
        if (t == null)
            return "Erro desconhecido.";

        Throwable cause = unwrapCause(t);

        String byConstraint = extractConstraintMessage(cause);
        if (byConstraint != null)
            return byConstraint;

        String sqlState = extractSqlState(cause);
        if ("23505".equals(sqlState)) { // UNIQUE_VIOLATION
            String constraintName = extractConstraintName(cause);
            if (constraintName != null && CONSTRAINT_MESSAGES.containsKey(constraintName)) {
                return CONSTRAINT_MESSAGES.get(constraintName);
            }
            return "Registro duplicado: já existe um registro com os mesmos dados.";
        }
        if ("23503".equals(sqlState)) { // FOREIGN_KEY_VIOLATION
            return "Operação inválida: existem relacionamentos que impedem esta ação.";
        }
        if ("23502".equals(sqlState)) { // NOT_NULL_VIOLATION
            return "Campo obrigatório não informado.";
        }
        if ("23514".equals(sqlState)) { // CHECK_VIOLATION
            return "Validação do banco não atendida.";
        }

        String msg = sanitizeMessage(cause.getMessage());
        if (msg != null && !msg.isBlank())
            return msg;

        try {
            SQLException sqlEx = findSqlException(cause);
            if (sqlEx != null) {
                SQLErrorCodeSQLExceptionTranslator translator = new SQLErrorCodeSQLExceptionTranslator();
                DataAccessException dataAccessEx = translator.translate("DB", null, sqlEx);
                if (dataAccessEx != null && dataAccessEx.getMessage() != null) {
                    return sanitizeMessage(dataAccessEx.getMessage());
                }
            }
        } catch (Exception ignore) {
        }

        return "Ocorreu um erro ao processar sua solicitação.";
    }

    private static Throwable unwrapCause(Throwable t) {
        Throwable cur = t;
        while (cur.getCause() != null && cur.getCause() != cur) {
            cur = cur.getCause();
        }
        return cur;
    }

    private static String extractSqlState(Throwable cause) {
        SQLException sqlEx = findSqlException(cause);
        return sqlEx != null ? sqlEx.getSQLState() : null;
    }

    private static String extractConstraintName(Throwable cause) {
        try {
            Object serverMsg = cause.getClass().getMethod("getServerErrorMessage").invoke(cause);
            if (serverMsg != null) {
                Object c = serverMsg.getClass().getMethod("getConstraint").invoke(serverMsg);
                return c != null ? c.toString() : null;
            }
        } catch (Exception e) {
        }
        String raw = cause.getMessage();
        if (raw != null) {
            java.util.regex.Matcher m = java.util.regex.Pattern.compile("constraint \"([^\"]+)\"").matcher(raw);
            if (m.find()) {
                return m.group(1);
            }
        }
        return null;
    }

    private static SQLException findSqlException(Throwable t) {
        Throwable cur = t;
        while (cur != null) {
            if (cur instanceof SQLException) {
                return (SQLException) cur;
            }
            cur = cur.getCause();
        }
        return null;
    }

    private static String extractConstraintMessage(Throwable cause) {
        // Se a exception contém nome da constraint, tenta mapear
        String constraint = extractConstraintName(cause);
        if (constraint != null) {
            String msg = CONSTRAINT_MESSAGES.get(constraint);
            if (msg != null)
                return msg;
        }
        return null;
    }

    private static String sanitizeMessage(String raw) {
        if (raw == null)
            return null;
        // Remove prefixos comuns técnicos
        String s = raw
                .replaceAll("org.postgresql.util.PSQLException: ", "")
                .replaceAll("ERROR: ", "")
                .replaceAll("Detalhe: ", "")
                .replaceAll("Detail: ", "")
                .trim();

        Matcher m = GENERIC_RAISE_MSG.matcher(s);
        if (m.find()) {
            s = m.group(1).trim();
        }

        if (!s.isEmpty()) {
            s = s.substring(0, 1).toUpperCase(Locale.forLanguageTag("pt-BR")) + s.substring(1);
        }
        return s;
    }
}
