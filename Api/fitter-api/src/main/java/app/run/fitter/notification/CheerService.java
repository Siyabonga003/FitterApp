package app.run.fitter.notification;

import app.run.fitter.websocket.ReactiveLocationWebSocketHandler;
import org.springframework.r2dbc.core.DatabaseClient;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;

import java.util.Map;
import java.util.UUID;

@Service
public class CheerService {

    private final DatabaseClient db;
    private final ReactiveLocationWebSocketHandler webSocketHandler;

    public CheerService(DatabaseClient db,
                        ReactiveLocationWebSocketHandler webSocketHandler) {
        this.db = db;
        this.webSocketHandler = webSocketHandler;
    }

    public Mono<Void> sendCheer(String senderUserId, String targetUserId) {
        return persistCheerNotification(senderUserId, targetUserId)
                .then(pushCheerThroughWebSocket(senderUserId, targetUserId));
    }

    private Mono<Void> persistCheerNotification(String senderUserId, String targetUserId) {
        return db.sql("""
                    INSERT INTO notification.notifications
                        (notification_id, user_id, sender_user_id, notification_type_id,
                         title, body, data_json, is_read, created_at)
                    VALUES
                        (:notificationId, :targetUserId::uuid, :senderUserId::uuid,
                         (SELECT notification_type_id FROM lookup.notification_types
                          WHERE code = 'CHEER' LIMIT 1),
                         'Cheer received! 👏',
                         'Someone is cheering you on!',
                         :dataJson::jsonb,
                         false,
                         now())
                """)
                .bind("notificationId", UUID.randomUUID())
                .bind("targetUserId", targetUserId)
                .bind("senderUserId", senderUserId)
                .bind("dataJson", """
                        {"type":"cheer","senderId":"%s"}
                        """.formatted(senderUserId))
                .fetch()
                .rowsUpdated()
                .then();
    }


    private Mono<Void> pushCheerThroughWebSocket(String senderUserId, String targetUserId) {
        var sink = webSocketHandler.getSinkForUser(targetUserId);
        if (sink == null) {
            // User is not currently connected — notification already persisted, nothing to do
            return Mono.empty();
        }

        // Emit a cheer event payload through the target user's existing sink
        String cheerPayload = """
                {"event":"cheer","senderId":"%s"}
                """.formatted(senderUserId);

        sink.tryEmitNext(cheerPayload);
        return Mono.empty();
    }
}