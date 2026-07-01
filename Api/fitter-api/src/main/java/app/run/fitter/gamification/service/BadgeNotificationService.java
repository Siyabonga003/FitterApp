package app.run.fitter.gamification.service;

import app.run.fitter.gamification.dto.BadgeDto;
import app.run.fitter.websocket.ReactiveLocationWebSocketHandler;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
public class BadgeNotificationService {

    private static final Logger log = LoggerFactory.getLogger(BadgeNotificationService.class);

    private final ReactiveLocationWebSocketHandler webSocketHandler;
    private final ObjectMapper objectMapper;

    public BadgeNotificationService(ReactiveLocationWebSocketHandler webSocketHandler,
                                     ObjectMapper objectMapper) {
        this.webSocketHandler = webSocketHandler;
        this.objectMapper = objectMapper;
    }

    public void notifyBadgeAwarded(UUID userId, BadgeDto badge) {
        var sink = webSocketHandler.getSinkForUser(userId.toString());
        if (sink == null) return;
        try {
            String payload = objectMapper.writeValueAsString(
                    java.util.Map.of(
                            "event", "badge_awarded",
                            "code", badge.code(),
                            "name", badge.name(),
                            "description", badge.description()
                    )
            );
            sink.tryEmitNext(payload);
        } catch (Exception e) {
            log.error("Failed to send badge notification: {}", e.getMessage());
        }
    }
}