package app.run.fitter.util;

import app.run.fitter.config.ConfigProperties;
import lombok.RequiredArgsConstructor;
import org.springframework.core.convert.converter.Converter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.oauth2.jwt.Jwt;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Map;

@RequiredArgsConstructor
public class KeycloakRoleConverter implements Converter<Jwt, Collection<GrantedAuthority>> {
    private final ConfigProperties configProperties;

    @Override
    @SuppressWarnings("unchecked")
    public Collection<GrantedAuthority> convert(Jwt jwt) {
        System.out.println("DEBUG JWT CLAIMS: " + jwt.getClaims()); //temp Debugging line to inspect JWT claims
        Collection<GrantedAuthority> authorities = new ArrayList<>();
        
        Map<String, Object> resourceAccess = jwt.getClaimAsMap("resource_access");
        if (resourceAccess != null) {
            Map<String, Object> clientAccess = (Map<String, Object>) resourceAccess.get("fitter-app");

            if (clientAccess != null && clientAccess.containsKey("roles")) {
                Collection<String> clientRoles = (Collection<String>) clientAccess.get("roles");
                authorities.addAll(
                        clientRoles.stream()
                                .map(role -> new SimpleGrantedAuthority("ROLE_" + role.toUpperCase()))
                                .toList()
                );
            }
        }

        // 2. Backup Fallback: Check global realm_access roles if client scopes missed parsing
        Map<String, Object> realmAccess = jwt.getClaimAsMap("realm_access");
        if (realmAccess != null && realmAccess.containsKey("roles")) {
            Collection<String> realmRoles = (Collection<String>) realmAccess.get("roles");
            authorities.addAll(
                    realmRoles.stream()
                            .filter(role -> role.equalsIgnoreCase("admin") || role.equalsIgnoreCase("user"))
                            .map(role -> new SimpleGrantedAuthority("ROLE_" + role.toUpperCase()))
                            .filter(auth -> !authorities.contains(auth)) // avoid duplicates
                            .toList()
            );
        }

        return authorities;
    }
}