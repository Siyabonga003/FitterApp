package app.run.fitter.app.service;

import app.run.fitter.app.dto.DevicesDTO;
import reactor.core.publisher.Mono;

import java.util.UUID;

public interface DevicesService {
    Mono<DevicesDTO.DeviceResponse> registerPushToken(UUID userId, DevicesDTO.RegisterPushTokenRequest registerPushTokenRequest);

    Mono<Void> removeDevice(UUID deviceId);
}
