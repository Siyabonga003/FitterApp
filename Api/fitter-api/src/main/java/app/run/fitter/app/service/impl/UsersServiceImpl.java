package app.run.fitter.app.service.impl;

import app.run.fitter.app.dto.UsersDTO;
import app.run.fitter.app.entity.Users;
import app.run.fitter.app.mapper.UsersMapper;
import app.run.fitter.app.repository.UsersRepository;
import app.run.fitter.app.service.UsersService;
import app.run.fitter.config.ConfigProperties;
import app.run.fitter.constant.PagedResponse;
import app.run.fitter.exception.ResourceNotFoundException;
import app.run.fitter.file.dto.MetadataDTO;
import app.run.fitter.file.service.MetadataService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.CachePut;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.core.io.buffer.DataBuffer;
import org.springframework.http.MediaType;
import org.springframework.http.codec.multipart.FilePart;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.ZonedDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class UsersServiceImpl implements UsersService {
    private final MetadataService metadataService;
    private final UsersRepository usersRepository;
    private final UsersMapper usersMapper;
    private final ConfigProperties configProperties;
    private final WebClient webClient = WebClient.create(); // ✅ Single clean instance

    @Override
    @Transactional
    @CacheEvict(value = "userProfile", allEntries = true)
    public Mono<UsersDTO.UserResponse> createUser(UsersDTO.CreateUserRequest createUserRequest) {
        // ✅ Provision in Keycloak first to get the real Keycloak-assigned UUID
        return provisionUserInKeycloak(createUserRequest)
                .flatMap(kcUserId -> {
                    Users entity = usersMapper.toEntity(createUserRequest);
                    entity.setUserId(kcUserId);    // ✅ Use Keycloak's actual UUID as DB primary key
                    entity.setKcUserId(kcUserId);  // ✅ Same ID for both
                    entity.setNewRecord(true);
                    return usersRepository.save(entity);
                })
                .map(usersMapper::toResponse);
    }

    /**
     * Helper method to interact reactively with the Keycloak Admin REST API endpoints
     */
    private Mono<UUID> provisionUserInKeycloak(UsersDTO.CreateUserRequest request) {
        // Step A: Fetch an Admin CLI OAuth token
        String tokenUrl = configProperties.getKeycloakBaseUri()
                + "/realms/" + configProperties.getClientRealm()
                + "/protocol/openid-connect/token";

        MultiValueMap<String, String> tokenBody = new LinkedMultiValueMap<>();
        tokenBody.add("grant_type", "client_credentials");
        tokenBody.add("client_id", configProperties.getKeycloakAdminId());
        tokenBody.add("client_secret", configProperties.getKeycloakAdminSecret());

        return webClient.post()
                .uri(tokenUrl)
                .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                .body(BodyInserters.fromFormData(tokenBody))
                .retrieve()
                .onStatus(status -> status.is4xxClientError() || status.is5xxServerError(),
                        clientResponse -> clientResponse.bodyToMono(String.class)
                                .doOnNext(body -> log.error("Keycloak token error — status: {}, body: {}", clientResponse.statusCode(), body))
                                .flatMap(body -> Mono.error(new RuntimeException("Keycloak token request failed: " + body))))
                .bodyToMono(Map.class)
                .map(response -> (String) response.get("access_token"))
                .flatMap(adminToken -> {
                    // Step B: POST the new user to Keycloak Admin API
                    String usersUrl = configProperties.getKeycloakBaseUri()
                            + "/admin/realms/" + configProperties.getClientRealm()
                            + "/users";

                    log.debug("Provisioning user in Keycloak — url: {}", usersUrl);

                    Map<String, Object> keycloakUserRepresentation = Map.of(
                            "username", request.getEmail(),
                            "email", request.getEmail(),
                            "enabled", true,
                            "emailVerified", true,
                            "credentials", List.of(Map.of(
                                    "type", "password",
                                    "value", request.getPassword(),
                                    "temporary", false
                            ))
                    );

                    return webClient.post()
                            .uri(usersUrl)
                            .headers(h -> h.setBearerAuth(adminToken))
                            .contentType(MediaType.APPLICATION_JSON)
                            .bodyValue(keycloakUserRepresentation)
                            .retrieve()
                            .onStatus(status -> status.is4xxClientError() || status.is5xxServerError(),
                                    clientResponse -> clientResponse.bodyToMono(String.class)
                                            .flatMap(body -> Mono.error(new RuntimeException("Keycloak user creation failed: " + body))))
                            .toBodilessEntity()
                            .map(response -> {
                                String location = response.getHeaders().getFirst("Location");
                                String kcId = location.substring(location.lastIndexOf('/') + 1);
                                log.debug("Keycloak assigned user ID: {}", kcId);
                                return UUID.fromString(kcId);
                            });
                });
    }

    @Override
    @Cacheable(value = "userProfile", key = "#userId")
    public Mono<UsersDTO.UserResponse> getUserProfile(UUID userId) {
        return usersRepository.findById(userId)
                .switchIfEmpty(Mono.error(new ResourceNotFoundException("user", userId.toString())))
                .map(usersMapper::toResponse);
    }

    @Override
    public Mono<UsersDTO.UserResponse> getUserByKcId(UUID kcUserId) {
        return usersRepository.findByKcUserId(kcUserId)
                .switchIfEmpty(Mono.error(new ResourceNotFoundException("user", kcUserId.toString())))
                .map(usersMapper::toResponse);
    }

    @Override
    public Mono<MetadataDTO.MetadataResponse> uploadProfilePicture(UUID userId, FilePart profilePicture) {
        return metadataService.storeFile(profilePicture, userId);
    }

    @Override
    public Mono<DataBuffer> getProfilePicture(UUID userId, UUID fieldId) {
        return metadataService.getFile(fieldId, userId);
    }

    @Override
    @Transactional
    @CachePut(value = "userProfile", key = "#userId")
    public Mono<UsersDTO.UserResponse> updateUserProfile(UUID userId, UsersDTO.UpdateUserRequest updateUserRequest) {
        return usersRepository.findById(userId)
                .switchIfEmpty(Mono.error(new ResourceNotFoundException("user", userId.toString())))
                .flatMap(existingUser -> {
                    Users updatedUser = usersMapper.updateEntity(updateUserRequest, existingUser);
                    return usersRepository.save(updatedUser);
                })
                .map(usersMapper::toResponse);
    }

    @Override
    @Transactional
    @CachePut(value = "userProfile", key = "#userId")
    public Mono<UsersDTO.UserResponse> updateUserPrivacy(UUID userId, UsersDTO.UpdateUserPrivacyRequest updateUserPrivacyRequest) {
        return usersRepository.findById(userId)
                .switchIfEmpty(Mono.error(new ResourceNotFoundException("user", userId.toString())))
                .flatMap(existingUser -> {
                    Users updatedUser = usersMapper.updateEntity(updateUserPrivacyRequest, existingUser);
                    return usersRepository.save(updatedUser);
                })
                .map(usersMapper::toResponse);
    }

    @Override
    @Cacheable(value = "userPublicProfile", key = "#userId")
    public Mono<UsersDTO.PublicUserResponse> getUserPublicProfile(UUID userId) {
        return usersRepository.findById(userId)
                .switchIfEmpty(Mono.error(new ResourceNotFoundException("user", userId.toString())))
                .map(usersMapper::toPublicResponse);
    }

    @Override
    public Mono<PagedResponse<UsersDTO.UserResponse>> searchUsers(UsersDTO.SearchUsersRequest searchUsersRequest) {
        String sortBy = validateSortBy(searchUsersRequest.getSortBy());
        String sortDir = validateSortDir(searchUsersRequest.getSortDir());
        int offset = searchUsersRequest.getPage() * searchUsersRequest.getSize();

        Mono<Long> totalCount = usersRepository.countWithFilters(
                searchUsersRequest.getEmail(),
                searchUsersRequest.getDisplayName(),
                searchUsersRequest.getFirstName(),
                searchUsersRequest.getLastName(),
                searchUsersRequest.getGender(),
                searchUsersRequest.getBirthDate(),
                searchUsersRequest.getBirthDateFrom(),
                searchUsersRequest.getBirthDateTo(),
                searchUsersRequest.getBio(),
                searchUsersRequest.getDefaultActivityVisibilityId(),
                searchUsersRequest.getDefaultRouteVisible(),
                searchUsersRequest.getDefaultLiveLocationShare(),
                searchUsersRequest.getIsActive()
        );

        Flux<UsersDTO.UserResponse> users = usersRepository.findWithFilters(
                searchUsersRequest.getEmail(),
                searchUsersRequest.getDisplayName(),
                searchUsersRequest.getFirstName(),
                searchUsersRequest.getLastName(),
                searchUsersRequest.getGender(),
                searchUsersRequest.getBirthDate(),
                searchUsersRequest.getBirthDateFrom(),
                searchUsersRequest.getBirthDateTo(),
                searchUsersRequest.getBio(),
                searchUsersRequest.getDefaultActivityVisibilityId(),
                searchUsersRequest.getDefaultRouteVisible(),
                searchUsersRequest.getDefaultLiveLocationShare(),
                searchUsersRequest.getIsActive(),
                sortBy,
                sortDir,
                searchUsersRequest.getSize(),
                offset
        ).map(usersMapper::toResponse);

        return Mono.zip(users.collectList(), totalCount)
                .map(tuple -> {
                    var content = tuple.getT1();
                    var totalElements = tuple.getT2();
                    int totalPages = (int) Math.ceil((double) totalElements / searchUsersRequest.getSize());

                    return PagedResponse.<UsersDTO.UserResponse>builder()
                            .content(content)
                            .totalElements(totalElements)
                            .totalPages(totalPages)
                            .currentPage(searchUsersRequest.getPage())
                            .size(searchUsersRequest.getSize())
                            .hasNext(searchUsersRequest.getPage() < totalPages - 1)
                            .hasPrevious(searchUsersRequest.getPage() > 0)
                            .build();
                });
    }

    @Override
    public Mono<Void> deleteUser(UUID userId) {
        return usersRepository.findById(userId)
                .switchIfEmpty(Mono.error(new ResourceNotFoundException("user", userId.toString())))
                .flatMap(existingUser -> {
                    existingUser.setIsDeleted(true);
                    existingUser.setDeletedAt(ZonedDateTime.now());
                    return usersRepository.save(existingUser);
                }).then();
    }

    private String validateSortBy(String sortBy) {
        if (sortBy == null) return "firstName";
        return switch (sortBy.toLowerCase()) {
            case "lastname", "last_name" -> "lastName";
            default -> "firstName";
        };
    }

    private String validateSortDir(String sortDir) {
        if (sortDir == null) return "ASC";
        return sortDir.equalsIgnoreCase("DESC") ? "DESC" : "ASC";
    }
}