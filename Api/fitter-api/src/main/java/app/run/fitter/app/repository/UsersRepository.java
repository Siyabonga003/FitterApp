package app.run.fitter.app.repository;

import app.run.fitter.app.entity.Users;
import org.springframework.data.r2dbc.repository.Query;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.LocalDate;
import java.util.UUID;

@Repository
public interface UsersRepository extends R2dbcRepository<Users, UUID> {

    // ✅ Look up a user by their Keycloak subject ID
    @Query("SELECT * FROM app.users WHERE kc_user_id = :kcUserId AND is_deleted = false")
    Mono<Users> findByKcUserId(@Param("kcUserId") UUID kcUserId);

    @Query("SELECT u.* FROM app.users u WHERE u.is_deleted = false " +
            "AND (:email IS NULL OR LOWER(u.email) LIKE LOWER(CONCAT('%', :email, '%'))) " +
            "AND (:displayName IS NULL OR LOWER(u.display_name) LIKE LOWER(CONCAT('%', :displayName, '%'))) " +
            "AND (:firstName IS NULL OR LOWER(u.first_name) LIKE LOWER(CONCAT('%', :firstName, '%'))) " +
            "AND (:lastName IS NULL OR LOWER(u.last_name) LIKE LOWER(CONCAT('%', :lastName, '%'))) " +
            "AND (:gender IS NULL OR u.gender = :gender) " +
            "AND (:birthDate IS NULL OR u.birth_date = :birthDate) " +
            "AND (:birthDateFrom IS NULL OR u.birth_date >= :birthDateFrom) " +
            "AND (:birthDateTo IS NULL OR u.birth_date <= :birthDateTo) " +
            "AND (:bio IS NULL OR LOWER(u.bio) LIKE LOWER(CONCAT('%', :bio, '%'))) " +
            "AND (:defaultActivityVisibilityId IS NULL OR u.default_activity_visibility_id = :defaultActivityVisibilityId) " +
            "AND (:defaultRouteVisible IS NULL OR u.default_route_visible = :defaultRouteVisible) " +
            "AND (:defaultLiveLocationShare IS NULL OR u.default_live_location_share = :defaultLiveLocationShare) " +
            "AND (:isActive IS NULL OR u.is_active = :isActive) " +
            "ORDER BY " +
            "CASE WHEN :sortBy = 'firstName' AND :sortDir = 'ASC' THEN u.first_name END," +
            "CASE WHEN :sortBy = 'firstName' AND :sortDir = 'DESC' THEN u.first_name END DESC," +
            "CASE WHEN :sortBy = 'lastName' AND :sortDir = 'ASC' THEN u.last_name END," +
            "CASE WHEN :sortBy = 'lastName' AND :sortDir = 'DESC' THEN u.last_name END DESC," +
            "u.user_id " +
            "LIMIT :limit OFFSET :offset"
    )
    Flux<Users> findWithFilters(
            @Param("email") String email,
            @Param("displayName") String displayName,
            @Param("firstName") String firstName,
            @Param("lastName") String lastName,
            @Param("gender") String gender,
            @Param("birthDate") LocalDate birthDate,
            @Param("birthDateFrom") LocalDate birthDateFrom,
            @Param("birthDateTo") LocalDate birthDateTo,
            @Param("bio") String bio,
            @Param("defaultActivityVisibilityId") Short defaultActivityVisibilityId,
            @Param("defaultRouteVisible") Boolean defaultRouteVisible,
            @Param("defaultLiveLocationShare") Boolean defaultLiveLocationShare,
            @Param("isActive") Boolean isActive,
            @Param("sortBy") String sortBy,
            @Param("sortDir") String sortDir,
            @Param("limit") Integer limit,
            @Param("offset") Integer offset
    );

    @Query("SELECT COUNT(*) FROM app.users u WHERE u.is_deleted = false " +
            "AND (:email IS NULL OR LOWER(u.email) LIKE LOWER(CONCAT('%', :email, '%'))) " +
            "AND (:displayName IS NULL OR LOWER(u.display_name) LIKE LOWER(CONCAT('%', :displayName, '%'))) " +
            "AND (:firstName IS NULL OR LOWER(u.first_name) LIKE LOWER(CONCAT('%', :firstName, '%'))) " +
            "AND (:lastName IS NULL OR LOWER(u.last_name) LIKE LOWER(CONCAT('%', :lastName, '%'))) " +
            "AND (:gender IS NULL OR u.gender = :gender) " +
            "AND (:birthDate IS NULL OR u.birth_date = :birthDate) " +
            "AND (:birthDateFrom IS NULL OR u.birth_date >= :birthDateFrom) " +
            "AND (:birthDateTo IS NULL OR u.birth_date <= :birthDateTo) " +
            "AND (:bio IS NULL OR LOWER(u.bio) LIKE LOWER(CONCAT('%', :bio, '%'))) " +
            "AND (:defaultActivityVisibilityId IS NULL OR u.default_activity_visibility_id = :defaultActivityVisibilityId) " +
            "AND (:defaultRouteVisible IS NULL OR u.default_route_visible = :defaultRouteVisible) " +
            "AND (:defaultLiveLocationShare IS NULL OR u.default_live_location_share = :defaultLiveLocationShare) " +
            "AND (:isActive IS NULL OR u.is_active = :isActive)"
    )
    Mono<Long> countWithFilters(
            @Param("email") String email,
            @Param("displayName") String displayName,
            @Param("firstName") String firstName,
            @Param("lastName") String lastName,
            @Param("gender") String gender,
            @Param("birthDate") LocalDate birthDate,
            @Param("birthDateFrom") LocalDate birthDateFrom,
            @Param("birthDateTo") LocalDate birthDateTo,
            @Param("bio") String bio,
            @Param("defaultActivityVisibilityId") Short defaultActivityVisibilityId,
            @Param("defaultRouteVisible") Boolean defaultRouteVisible,
            @Param("defaultLiveLocationShare") Boolean defaultLiveLocationShare,
            @Param("isActive") Boolean isActive
    );
}