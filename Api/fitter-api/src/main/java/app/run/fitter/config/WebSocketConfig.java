package app.run.fitter.config;

import java.util.Map;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.reactive.HandlerMapping;
import org.springframework.web.reactive.handler.SimpleUrlHandlerMapping;
import org.springframework.web.reactive.socket.WebSocketHandler;
import org.springframework.web.reactive.socket.server.support.WebSocketHandlerAdapter;

import app.run.fitter.websocket.ReactiveLocationWebSocketHandler;

@Configuration
public class WebSocketConfig {

    private final ReactiveLocationWebSocketHandler locationHandler;

    public WebSocketConfig(ReactiveLocationWebSocketHandler locationHandler) {
        this.locationHandler = locationHandler;
    }

    @Bean
    public HandlerMapping webSocketHandlerMapping() {
        Map<String, WebSocketHandler> map = Map.of(
            "/ws/location", locationHandler
        );
        SimpleUrlHandlerMapping mapping = new SimpleUrlHandlerMapping();
        mapping.setUrlMap(map);
        mapping.setOrder(-1);
        return mapping;
    }

    @Bean
    public WebSocketHandlerAdapter webSocketHandlerAdapter() {
        return new WebSocketHandlerAdapter();
    }

    @Bean
    public org.springframework.web.reactive.socket.server.RequestUpgradeStrategy requestUpgradeStrategy() {
        return new org.springframework.web.reactive.socket.server.upgrade.ReactorNettyRequestUpgradeStrategy();
    }
}