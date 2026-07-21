package app.run.fitter.app.controller;

import app.run.fitter.app.dto.UsersDTO;
import app.run.fitter.app.service.UsersService;
import app.run.fitter.constant.ErrorResponse;
import app.run.fitter.constant.PagedResponse;
import app.run.fitter.file.dto.MetadataDTO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.buffer.DataBuffer;
import org.springframework.http.ResponseEntity;
import org.springframework.http.codec.multipart.FilePart;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;
import org.springframework.http.MediaType;

import java.time.LocalDate;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
@Validated
@Tag(name = "users", description = "Endpoints for users API")
public class UsersController {
    private final UsersService usersService;

    @Operation(summary = "Create user", description = "create user")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "User created successfully"),
            @ApiResponse(
                    responseCode = "400",
                    description = "Invalid input",
                    content = @Content(schema = @Schema(implementation = ErrorResponse.class))
            )
    })
    @PostMapping
    public Mono<ResponseEntity<UsersDTO.UserResponse>> createUser(
            @RequestBody UsersDTO.CreateUserRequest createUserRequest
    ) {
        return usersService.createUser(createUserRequest)
                .map(ResponseEntity::ok);
    }

    @Operation(summary = "Get user profile", description = "get user profile")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "User profile retrieved successfully"),
            @ApiResponse(responseCode = "404", description = "User profile not retrieved")
    })
    @GetMapping("/me/{userId}")
    @PreAuthorize("hasAnyRole('ROLE_USER')")
    public Mono<ResponseEntity<UsersDTO.UserResponse>> getUserProfile(
            @PathVariable("userId") UUID userId
    ) {
        return usersService.getUserProfile(userId)
                .map(ResponseEntity::ok)
                .onErrorResume(e -> Mono.just(ResponseEntity.notFound().build()));
    }

    // ✅ New endpoint — look up DB user by Keycloak subject ID (used after login to get the real DB userId)
    @Operation(summary = "Get user by Keycloak ID", description = "get user profile by keycloak subject id")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "User profile retrieved successfully"),
            @ApiResponse(responseCode = "404", description = "User not found")
    })
    @GetMapping("/me/kc/{kcUserId}")
    @PreAuthorize("hasAnyRole('ROLE_USER')")
    public Mono<ResponseEntity<UsersDTO.UserResponse>> getUserByKcId(
            @PathVariable("kcUserId") UUID kcUserId
    ) {
        return usersService.getUserByKcId(kcUserId)
                .map(ResponseEntity::ok)
                .onErrorResume(e -> Mono.just(ResponseEntity.notFound().build()));
    }



    @Operation(summary = "Upload profile picture", description = "upload profile picture")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Profile picture uploaded successfully"),
            @ApiResponse(responseCode = "400", description = "Profile picture not uploaded")
    })
    @PostMapping("/me/{userId}/profile-picture")
    @PreAuthorize("hasAnyRole('ROLE_USER')")
    public Mono<ResponseEntity<MetadataDTO.MetadataResponse>> uploadProfilePicture(
            @PathVariable("userId") UUID userId,
            @RequestPart("profilePicture") FilePart profilePicture
    ) {
        return usersService.uploadProfilePicture(userId, profilePicture)
                .map(ResponseEntity::ok);
    }

    @Operation(summary = "Get profile picture", description = "get profile picture")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Profile picture retrieved successfully"),
            @ApiResponse(responseCode = "404", description = "Profile picture not retrieved")
    })
    @GetMapping("/me/{userId}/profile-picture/{fieldId}")
    public Mono<ResponseEntity<DataBuffer>> getProfilePicture(
            @PathVariable("userId") UUID userId,
            @PathVariable("fieldId") UUID fieldId
    ) {
        return usersService.getProfilePicture(userId, fieldId)
                .map(content -> ResponseEntity.ok()
                        .contentType(MediaType.parseMediaType(content.mimeType()))
                        .body(content.data()));
    }

    @Operation(summary = "Get user public profile", description = "get user public profile")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "User public profile retrieved successfully"),
            @ApiResponse(responseCode = "404", description = "User public profile not retrieved")
    })
    @GetMapping("/{userId}")
    @PreAuthorize("hasAnyRole('ROLE_USER')")
    public Mono<ResponseEntity<UsersDTO.PublicUserResponse>> getUserPublicProfile(
            @PathVariable("userId") UUID userId
    ) {
        return usersService.getUserPublicProfile(userId)
                .map(ResponseEntity::ok)
                .onErrorResume(e -> Mono.just(ResponseEntity.notFound().build()));
    }

    @Operation(summary = "Update user profile", description = "update user profile")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "User profile updated successfully"),
            @ApiResponse(responseCode = "400", description = "User profile not updated")
    })
    @PutMapping("/me/{userId}")
    @PreAuthorize("hasAnyRole('ROLE_USER')")
    public Mono<ResponseEntity<UsersDTO.UserResponse>> updateUserProfile(
            @PathVariable("userId") UUID userId,
            @RequestBody UsersDTO.UpdateUserRequest updateUserRequest
    ) {
        return usersService.updateUserProfile(userId, updateUserRequest)
                .map(ResponseEntity::ok)
                .onErrorResume(e -> Mono.just(ResponseEntity.badRequest().build()));
    }

    @Operation(summary = "Update user privacy", description = "update user privacy")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "User privacy updated successfully"),
            @ApiResponse(responseCode = "400", description = "User privacy not updated")
    })
    @PutMapping("/me/{userId}/privacy")
    @PreAuthorize("hasAnyRole('ROLE_USER')")
    public Mono<ResponseEntity<UsersDTO.UserResponse>> updateUserPrivacy(
            @PathVariable("userId") UUID userId,
            @RequestBody UsersDTO.UpdateUserPrivacyRequest updateUserPrivacyRequest
    ) {
        return usersService.updateUserPrivacy(userId, updateUserPrivacyRequest)
                .map(ResponseEntity::ok)
                .onErrorResume(e -> Mono.just(ResponseEntity.badRequest().build()));
    }

    @Operation(summary = "Search users", description = "search users")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Users found successfully"),
            @ApiResponse(responseCode = "404", description = "Users not found")
    })
    @GetMapping("/search")
    @PreAuthorize("hasAnyRole('ROLE_USER')")
    public Mono<ResponseEntity<PagedResponse<UsersDTO.UserResponse>>> searchUsers(
            @RequestParam(value = "email", required = false) String email,
            @RequestParam(value = "displayName", required = false) String displayName,
            @RequestParam(value = "firstName", required = false) String firstName,
            @RequestParam(value = "lastName", required = false) String lastName,
            @RequestParam(value = "gender", required = false) String gender,
            @RequestParam(value = "birthDate", required = false) LocalDate birthDate,
            @RequestParam(value = "birthDateFrom", required = false) LocalDate birthDateFrom,
            @RequestParam(value = "birthDateTo", required = false) LocalDate birthDateTo,
            @RequestParam(value = "bio", required = false) String bio,
            @RequestParam(value = "defaultActivityVisibilityId", required = false) Short defaultActivityVisibilityId,
            @RequestParam(value = "defaultRouteVisible", required = false) Boolean defaultRouteVisible,
            @RequestParam(value = "defaultLiveLocationShare", required = false) Boolean defaultLiveLocationShare,
            @RequestParam(value = "isActive", required = false) Boolean isActive,
            @RequestParam(defaultValue = "firstName") String sortBy,
            @RequestParam(defaultValue = "ASC") String sortDir,
            @RequestParam(defaultValue = "0") Integer page,
            @RequestParam(defaultValue = "20") Integer size
    ) {
        return usersService.searchUsers(UsersDTO.SearchUsersRequest.builder()
                        .email(email)
                        .displayName(displayName)
                        .firstName(firstName)
                        .lastName(lastName)
                        .gender(gender)
                        .birthDate(birthDate)
                        .birthDateFrom(birthDateFrom)
                        .birthDateTo(birthDateTo)
                        .bio(bio)
                        .defaultActivityVisibilityId(defaultActivityVisibilityId)
                        .defaultRouteVisible(defaultRouteVisible)
                        .defaultLiveLocationShare(defaultLiveLocationShare)
                        .isActive(isActive)
                        .sortBy(sortBy)
                        .sortDir(sortDir)
                        .page(page)
                        .size(size)
                .build())
                .map(ResponseEntity::ok)
                .onErrorResume(e -> Mono.just(ResponseEntity.notFound().build()));
    }

    @Operation(summary = "Delete user", description = "delete user")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "User deleted successfully"),
            @ApiResponse(responseCode = "400", description = "User not deleted")
    })
    @DeleteMapping("/{userId}")
    @PreAuthorize("hasAnyRole('ROLE_USER')")
    public Mono<ResponseEntity<Void>> deleteUser(
            @PathVariable("userId") UUID userId
    ) {
        return usersService.deleteUser(userId)
                .map(ResponseEntity::ok)
                .onErrorResume(e -> Mono.just(ResponseEntity.badRequest().build()));
    }
}