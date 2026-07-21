package app.run.fitter.app.service;

import app.run.fitter.app.dto.UsersDTO;
import app.run.fitter.constant.PagedResponse;
import app.run.fitter.file.dto.FileContent;
import app.run.fitter.file.dto.MetadataDTO;
import org.springframework.http.codec.multipart.FilePart;
import reactor.core.publisher.Mono;

import java.util.UUID;

public interface UsersService {
    Mono<UsersDTO.UserResponse> createUser(UsersDTO.CreateUserRequest createUserRequest);

    Mono<UsersDTO.UserResponse> getUserProfile(UUID userId);

    Mono<UsersDTO.UserResponse> getUserByKcId(UUID kcUserId); 

    Mono<MetadataDTO.MetadataResponse> uploadProfilePicture(UUID userId, FilePart profilePicture);

    Mono<FileContent> getProfilePicture(UUID userId, UUID fieldId);

    Mono<UsersDTO.UserResponse> updateUserProfile(UUID userId, UsersDTO.UpdateUserRequest updateUserRequest);

    Mono<UsersDTO.UserResponse> updateUserPrivacy(UUID userId, UsersDTO.UpdateUserPrivacyRequest updateUserPrivacyRequest);

    Mono<UsersDTO.PublicUserResponse> getUserPublicProfile(UUID userId);

    Mono<PagedResponse<UsersDTO.UserResponse>> searchUsers(UsersDTO.SearchUsersRequest searchUsersRequest);

    Mono<Void> deleteUser(UUID userId);
}