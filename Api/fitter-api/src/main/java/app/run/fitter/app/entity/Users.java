package app.run.fitter.app.entity;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Transient;
import org.springframework.data.domain.Persistable;
import org.springframework.data.relational.core.mapping.Table;

import java.time.LocalDate;
import java.time.ZonedDateTime;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(schema = "app", name = "users")
public class Users implements Persistable<UUID> {
    @Id
    private UUID userId;
    private UUID kcUserId;
    private String email;
    private String displayName;
    private String firstName;
    private String lastName;
    private String gender;
    private LocalDate birthDate;
    @Transient
    private String profilePictureUrl;
    private String bio;
    private Short defaultActivityVisibilityId;
    private Boolean defaultRouteVisible;
    private Boolean defaultLiveLocationShare;
    private Boolean isActive;
    private Boolean isDeleted;
    private ZonedDateTime deletedAt;
    @CreatedDate
    private ZonedDateTime createdAt;
    private ZonedDateTime updatedAt;

    @Transient
    @Builder.Default
    private boolean isNewRecord = false; 

    @Override
    public UUID getId() {
        return userId;
    }

    @Override
    public boolean isNew() {
        return isNewRecord;
    }
}