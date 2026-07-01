package app.run.fitter.config;

import lombok.Getter;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Getter
@ConfigurationProperties(prefix = "config")
@Configuration
public class ConfigProperties {
    @Value("${spring.r2dbc.username}")
    private String dbUsername;

    @Value("${spring.r2dbc.password}")
    private String dbPassword;

    @Value("${spring.r2dbc.url}")
    private String dbUrl;

    @Value("${spring.keycloak.url}")
    private String keycloakBaseUri;

    @Value("${spring.keycloak.client-realm}")
    private String clientRealm;

    @Value("${spring.security.oauth2.resourceserver.jwt.jwk-set-uri}")
    private String jwkSetUri;

    
    @Value("${spring.security.oauth2.resourceserver.jwt.issuer-uri:}")
    private String issuerUri;

    @Value("${spring.flyway.url}")
    private String flywayUrl;

    @Value("${spring.flyway.user}")
    private String flywayUser;

    @Value("${spring.flyway.password}")
    private String flywayPassword;

    @Value("${spring.flyway.locations}")
    private String flywayLocations;

    @Value("${spring.cors.allowed-origins}")
    private String allowedOrigins;

    @Value("${spring.cors.allowed-methods}")
    private String[] allowedMethods;

    @Value("${spring.cors.allowed-headers}")
    private String allowedHeaders;

    @Value("${spring.cors.allow-credentials}")
    private boolean allowCredentials;

    @Value("${spring.keycloak.client-id}")
    private String keycloakClientId;

    @Value("${spring.keycloak.admin-id}")
    private String keycloakAdminId;

    @Value("${spring.keycloak.admin-secret}")
    private String keycloakAdminSecret;

    @Value("${spring.keycloak.default-role}")
    private String keycloakDefaultRole;

    @Value("${file.storage.base-path}")
    private String fileStorageBasePath;

    @Value("${file.storage.max-size}")
    private Long fileStorageMaxSize;

    @Value("${file.storage.max-files-per-request}")
    private Integer fileStorageMaxFilesPerRequest;

    @Value("${file.storage.allowed-mime-types}")
    private String fileStorageAllowedMimeTypes;
}