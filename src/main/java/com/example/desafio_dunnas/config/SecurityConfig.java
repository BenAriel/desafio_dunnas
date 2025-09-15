package com.example.desafio_dunnas.config;

import org.springframework.boot.autoconfigure.security.servlet.PathRequest;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.annotation.Order;

import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.context.HttpSessionSecurityContextRepository;
import org.springframework.security.web.context.SecurityContextRepository;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;

import jakarta.servlet.DispatcherType;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {

        http
                .authorizeHttpRequests(authorize -> authorize
                        .dispatcherTypeMatchers(DispatcherType.FORWARD).permitAll()

                        .requestMatchers("/login", "/registrar", "/test", "/css/**", "/js/**", "/static/**").permitAll()
                        .requestMatchers("/admin/**").hasAuthority("ROLE_ADMIN")
                        .requestMatchers("/recepcionista/**").hasAuthority("ROLE_RECEPCIONISTA")
                        .requestMatchers("/cliente/**").hasAuthority("ROLE_CLIENTE")
                        .anyRequest().authenticated())
        .formLogin(form -> form
            .loginPage("/login")
            .loginProcessingUrl("/login")
            .usernameParameter("email")
            .passwordParameter("password")
            .successHandler(authenticationSuccessHandler())
            .failureUrl("/login?error")
            .permitAll())
                .logout(logout -> logout
                        .logoutUrl("/logout")
                        .logoutSuccessUrl("/login?logout")
                        .permitAll());

        return http.build();
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration configuration) throws Exception {
        return configuration.getAuthenticationManager();
    }

    @Bean
    public SecurityContextRepository securityContextRepository() {
        return new HttpSessionSecurityContextRepository();
    }

    @Bean
    public AuthenticationSuccessHandler authenticationSuccessHandler() {
        return (request, response, authentication) -> {
            String target = "/";
            boolean isAdmin = authentication.getAuthorities().stream()
                    .anyMatch(a -> "ROLE_ADMIN".equals(a.getAuthority()));
            boolean isRecep = authentication.getAuthorities().stream()
                    .anyMatch(a -> "ROLE_RECEPCIONISTA".equals(a.getAuthority()));
            boolean isCliente = authentication.getAuthorities().stream()
                    .anyMatch(a -> "ROLE_CLIENTE".equals(a.getAuthority()));

            if (isAdmin) {
                target = "/admin?success=admin logado com sucesso";
            } else if (isRecep) {
                target = "/recepcionista?success=login realizado com sucesso";
            } else if (isCliente) {
                target = "/cliente?success=login realizado com sucesso";
            }
            response.sendRedirect(request.getContextPath() + target);
        };
    }

    @Configuration
    @Order(1)
    public static class StaticResourcesConfig {
        @Bean
        public SecurityFilterChain staticResourceFilterChain(HttpSecurity http) throws Exception {
            return http
                    .securityMatcher(PathRequest.toStaticResources().atCommonLocations())
                    .authorizeHttpRequests(auth -> auth.anyRequest().permitAll())
                    .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                    .csrf(AbstractHttpConfigurer::disable)
                    .build();
        }
    }
}