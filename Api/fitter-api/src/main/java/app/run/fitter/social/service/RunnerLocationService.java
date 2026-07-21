package app.run.fitter.social.service;

import app.run.fitter.social.dto.LocationUpdateDto;
import app.run.fitter.social.entity.RunnerLocation;
import app.run.fitter.social.repository.RunnerLocationRepository;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.Instant;
import java.util.List;

@Service
public class RunnerLocationService {

    private final RunnerLocationRepository repository;

    public RunnerLocationService(RunnerLocationRepository repository) {
        this.repository = repository;
    }

    public Mono<RunnerLocation> upsertLocation(String userId, LocationUpdateDto dto) {
        return repository.findById(userId)
                .defaultIfEmpty(new RunnerLocation())
                .map(location -> {
                    location.setUserId(userId);
                    location.setLatitude(dto.latitude());
                    location.setLongitude(dto.longitude());
                    location.setPaceKmPerMin(dto.pace());
                    location.setDistanceKm(dto.distance());
                    location.setSharingLive(dto.sharingLive());
                    location.setUpdatedAt(Instant.now());
                    return location;
                })
                .flatMap(repository::save);
    }

    public Flux<RunnerLocation> getLiveFriendLocations(List<String> friendIds) {
        return repository.findLiveFriends(friendIds);
    }

    public Flux<RunnerLocation> getAllLivePresence() {
        return repository.findAllLivePresence(Instant.now().minusSeconds(300));
    }

    public Mono<Long> getLivePresenceCount() {
        return repository.countLivePresence(Instant.now().minusSeconds(300));
    }
}