package com.example.desafio_dunnas.config;

import java.sql.SQLException;
import java.util.Locale;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.support.SQLErrorCodeSQLExceptionTranslator;

public final class DbErrorMessageResolver {

    // Remove blocos "Onde:"/"Where:" e trechos técnicos de PL/pgSQL
    private static final Pattern WHERE_BLOCK_PATTERN = Pattern.compile("(?is)\\n\\s*(onde|where):.*$");
    private static final Pattern PLSQL_TECH_PATTERN = Pattern.compile("(?is)(fun[cç][aã]o\n?\s*pl/pgsql.*)$");
    private static final Pattern MULTILINE_FIRST_LINE = Pattern.compile("^([^\n\r]+)");

    private static final Map<String, String> CONSTRAINT_MESSAGES = Map.ofEntries(
            Map.entry("ux_recepcionista_setor", "Este setor já possui um recepcionista alocado."),
            Map.entry("tb_usuarios_email_key", "Este e-mail já está cadastrado."),
            Map.entry("tb_administradores_matricula_key", "Esta matrícula já está cadastrada."),
            Map.entry("tb_administradores_cpf_key", "Este CPF já está cadastrado."),
            Map.entry("tb_recepcionistas_matricula_key", "Esta matrícula já está cadastrada."),
            Map.entry("tb_recepcionistas_cpf_key", "Este CPF já está cadastrado."),
            Map.entry("tb_clientes_telefone_key", "Este telefone já está cadastrado."),
            Map.entry("chk_administradores_cpf_11dig", "CPF deve ter 11 dígitos numéricos."),
            Map.entry("chk_recepcionistas_cpf_11dig", "CPF deve ter 11 dígitos numéricos."),
            Map.entry("chk_clientes_tel_11dig", "Telefone deve ter 11 dígitos numéricos."),
            Map.entry("ux_sala_nome_setor", "Já existe uma sala com este nome neste setor."));

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
        // Observação: poderíamos inspecionar getServerErrorMessage() quando disponível,
        // mas aqui focamos em sanitizar a string de mensagem recebida.

        // Remove prefixos e blocos técnicos
        String s = raw
                .replaceAll("org.postgresql.util.PSQLException: ", "")
                .replaceAll("(?i)ERROR: ", "")
                .replaceAll("(?i)Detalhe: ", "")
                .replaceAll("(?i)Detail: ", "")
                .replaceAll("\r", "")
                .trim();

        // Remove bloco 'Onde:'/'Where:' e assinaturas PL/pgSQL
        s = WHERE_BLOCK_PATTERN.matcher(s).replaceAll("");
        s = PLSQL_TECH_PATTERN.matcher(s).replaceAll("");

        // Fica apenas com a primeira linha
        Matcher first = MULTILINE_FIRST_LINE.matcher(s);
        if (first.find()) {
            s = first.group(1).trim();
        }

        if (!s.isEmpty()) {
            s = s.substring(0, 1).toUpperCase(Locale.forLanguageTag("pt-BR")) + s.substring(1);
        }

        // Se sobrar vazio, retorna fallback genérico
        if (s.isBlank()) {
            return "Ocorreu um erro ao processar sua solicitação.";
        }
        return s;
    }
}
