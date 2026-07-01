package app.run.fitter.notification.repository;

import app.run.fitter.notification.entity.Notifications;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface NotificationsRepository extends R2dbcRepository<Notifications, UUID> {
}
