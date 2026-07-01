package app.run.fitter.websocket;

import com.fasterxml.jackson.databind.ObjectMapper;

import app.run.fitter.social.dto.LocationUpdateDto;
import app.run.fitter.social.service.RunnerLocationService;
import app.run.fitter.websocket.ReactiveLocationWebSocketHandler;

import org.springframework.stereotype.Component;
import org.springframework.web.reactive.socket.WebSocketHandler;
import org.springframework.web.reactive.socket.WebSocketSession;
import reactor.core.publisher.Mono;
import reactor.core.publisher.Sinks;

import java.util.concurrent.ConcurrentHashMap;

@Component
public class ReactiveLocationWebSocketHandler implements WebSocketHandler {

    private final RunnerLocationService locationService;
    private final ObjectMapper objectMapper;

    private final ConcurrentHashMap<String, Sinks.Many<String>> userSinks =
            new ConcurrentHashMap<>();

    public ReactiveLocationWebSocketHandler(RunnerLocationService locationService,
                                            ObjectMapper objectMapper) {
        this.locationService = locationService;
        this.objectMapper = objectMapper;
    }

    @Override
    public Mono<Void> handle(WebSocketSession session) {
        Mono<String> userIdMono = session.getHandshakeInfo()
                .getPrincipal()
                .map(principal -> principal.getName());

        return userIdMono.flatMap(userId -> {
            Sinks.Many<String> sink = userSinks.computeIfAbsent(
                    userId,
                    id -> Sinks.many().multicast().onBackpressureBuffer()
            );

            Mono<Void> inbound = session.receive()
                    .flatMap(message -> {
                        try {
                            LocationUpdateDto dto = objectMapper.readValue(
                                    message.getPayloadAsText(),
                                    LocationUpdateDto.class
                            );
                            return locationService.upsertLocation(userId, dto)
                                    .flatMap(saved -> {
                                        try {
                                            String json = objectMapper.writeValueAsString(saved);
                                            sink.tryEmitNext(json);
                                            return Mono.empty();
                                        } catch (Exception e) {
                                            return Mono.error(
                                                new RuntimeException("Serialization failed", e)
                                            );
                                        }
                                    });
                        } catch (Exception e) {
                            return Mono.error(
                                new IllegalArgumentException("Invalid location payload", e)
                            );
                        }
                    })
                    .then();
   
            Mono<Void> outbound = session.send(
                    sink.asFlux().map(session::textMessage)
            );

            return Mono.zip(inbound, outbound)
                    .then()
                    .doFinally(signal -> userSinks.remove(userId));
        });
    }

    public Sinks.Many<String> getSinkForUser(String userId) {
        return userSinks.get(userId);
    }
}