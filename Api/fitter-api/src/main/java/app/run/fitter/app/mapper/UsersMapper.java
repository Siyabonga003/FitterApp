package app.run.fitter.app.mapper;

import app.run.fitter.app.dto.UsersDTO;
import app.run.fitter.app.entity.Users;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;
import org.mapstruct.NullValuePropertyMappingStrategy;

@Mapper(
        componentModel = "spring",
        nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE
)
public interface UsersMapper {
    @Mapping(target = "userId", ignore = true)         // ✅ Set manually in service via UUID.randomUUID()
    @Mapping(target = "kcUserId", ignore = true)       // ✅ Set manually in service (same shared UUID)
    @Mapping(target = "profilePictureUrl", ignore = true)
    @Mapping(target = "deletedAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    Users toEntity(UsersDTO.CreateUserRequest createUserRequest);

    UsersDTO.UserResponse toResponse(Users users);

    UsersDTO.PublicUserResponse toPublicResponse(Users users);

    @Mapping(target = "userId", ignore = true)
    @Mapping(target = "profilePictureUrl", ignore = true)
    @Mapping(target = "deletedAt", ignore = true)
    @Mapping(target = "defaultActivityVisibilityId", ignore = true)
    @Mapping(target = "defaultRouteVisible", ignore = true)
    @Mapping(target = "defaultLiveLocationShare", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "isDeleted", ignore = true)
    Users updateEntity(UsersDTO.UpdateUserRequest updateUserRequest, @MappingTarget Users users);

    @Mapping(target = "userId", ignore = true)
    @Mapping(target = "kcUserId", ignore = true)
    @Mapping(target = "email", ignore = true)
    @Mapping(target = "displayName", ignore = true)
    @Mapping(target = "firstName", ignore = true)
    @Mapping(target = "lastName", ignore = true)
    @Mapping(target = "gender", ignore = true)
    @Mapping(target = "birthDate", ignore = true)
    @Mapping(target = "profilePictureUrl", ignore = true)
    @Mapping(target = "bio", ignore = true)
    @Mapping(target = "isActive", ignore = true)
    @Mapping(target = "deletedAt", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "isDeleted", ignore = true)
    Users updateEntity(UsersDTO.UpdateUserPrivacyRequest updateUserPrivacyRequest, @MappingTarget Users users);
}