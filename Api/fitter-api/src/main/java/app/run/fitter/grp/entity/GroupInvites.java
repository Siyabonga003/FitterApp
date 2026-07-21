package app.run.fitter.grp.entity;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Transient;
import org.springframework.data.domain.Persistable;
import org.springframework.data.relational.core.mapping.Table;

import java.time.ZonedDateTime;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(schema = "grp", name = "group_invites")
public class GroupInvites implements Persistable<UUID> {
    @Id
    private UUID inviteId;
    private UUID groupId;
    private String code;
    private UUID createdBy;
    private Integer maxUses;
    private Integer useCount;
    private ZonedDateTime expiresAt;
    private Boolean isActive;
    private ZonedDateTime createdAt;

    @Transient
    private boolean isNewRecord;

    @Override
    public UUID getId() {
        return inviteId;
    }

    @Override
    public boolean isNew() {
        return isNewRecord;
    }
}