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

import java.time.ZonedDateTime;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(schema = "app", name = "friendships")
public class Friendships implements Persistable<UUID> {

    @Id
    private UUID friendshipId;
    private UUID userId;
    private UUID friendId;
    private String status;

    @CreatedDate
    private ZonedDateTime createdAt;

    @Transient
    @Builder.Default
    private boolean isNew = false;

    @Override
    public UUID getId() {
        return friendshipId;
    }

    @Override
    public boolean isNew() {
        return isNew;
    }
}