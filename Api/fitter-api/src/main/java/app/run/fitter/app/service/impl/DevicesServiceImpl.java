package app.run.fitter.app.service.impl;

import app.run.fitter.app.dto.DevicesDTO;
import app.run.fitter.app.service.DevicesService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class DevicesServiceImpl implements DevicesService {
    @Override
    public Mono<DevicesDTO.DeviceResponse> registerPushToken(UUID userId, DevicesDTO.RegisterPushTokenRequest registerPushTokenRequest) {
        return null;
    }

    @Override
    public Mono<Void> removeDevice(UUID deviceId) {
        return null;
    }
}
