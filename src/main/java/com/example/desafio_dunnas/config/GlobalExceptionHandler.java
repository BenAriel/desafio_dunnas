package com.example.desafio_dunnas.config;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.server.ResponseStatusException;

@ControllerAdvice
public class GlobalExceptionHandler {

        @ExceptionHandler({ DataIntegrityViolationException.class })
        public ResponseEntity<ApiResponse<Object>> handleDataIntegrity(Exception ex, WebRequest request) {
                String friendly = DbErrorMessageResolver.resolve(ex);
                ApiError apiError = new ApiError("db", friendly);
                ApiResponse<Object> response = new ApiResponse<>(
                                false,
                                friendly,
                                null,
                                java.util.List.of(apiError),
                                HttpStatus.BAD_REQUEST.value(),
                                System.currentTimeMillis(),
                                request.getDescription(false).replace("uri=", ""));
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                                .contentType(org.springframework.http.MediaType.APPLICATION_JSON)
                                .body(response);
        }

        @ExceptionHandler(ResponseStatusException.class)
        public ResponseEntity<ApiResponse<Object>> handleResponseStatusException(ResponseStatusException ex,
                        WebRequest request) {
                ApiError apiError = new ApiError("error", ex.getReason() != null ? ex.getReason() : ex.getMessage());
                ApiResponse<Object> response = new ApiResponse<>(
                                false,
                                ex.getReason() != null ? ex.getReason() : ex.getMessage(),
                                null,
                                java.util.List.of(apiError),
                                ex.getStatusCode().value(),
                                System.currentTimeMillis(),
                                request.getDescription(false).replace("uri=", ""));
                return ResponseEntity.status(ex.getStatusCode())
                                .contentType(org.springframework.http.MediaType.APPLICATION_JSON)
                                .body(response);
        }

        @ExceptionHandler(MethodArgumentNotValidException.class)
        public ResponseEntity<ApiResponse<Object>> handleValidationException(MethodArgumentNotValidException ex,
                        WebRequest request) {
                var errors = ex.getBindingResult().getFieldErrors().stream()
                                .map(e -> new ApiError(e.getField(), e.getDefaultMessage()))
                                .toList();
                String message = "Erro de validação";
                ApiResponse<Object> response = new ApiResponse<>(
                                false,
                                message,
                                null,
                                errors,
                                HttpStatus.BAD_REQUEST.value(),
                                System.currentTimeMillis(),
                                request.getDescription(false).replace("uri=", ""));
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
        }

        @ExceptionHandler(Exception.class)
        public ResponseEntity<ApiResponse<Object>> handleGenericException(Exception ex, WebRequest request) {
                String friendly = DbErrorMessageResolver.resolve(ex);
                ApiError apiError = new ApiError("error", friendly);
                ApiResponse<Object> response = new ApiResponse<>(
                                false,
                                friendly,
                                null,
                                java.util.List.of(apiError),
                                HttpStatus.INTERNAL_SERVER_ERROR.value(),
                                System.currentTimeMillis(),
                                request.getDescription(false).replace("uri=", ""));
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
}