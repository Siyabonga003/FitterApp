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
@Table(schema = "grp", name = "group_members")
public class GroupMembers implements Persistable<UUID> {
    @Id
    private UUID groupMemberId;
    private UUID groupId;
    private UUID userId;
    private String role;
    private String status;
    private ZonedDateTime joinedAt;

    @Transient
    private boolean isNewRecord;

    @Override
    public UUID getId() {
        return groupMemberId;
    }

    @Override
    public boolean isNew() {
        return isNewRecord;
    }
}