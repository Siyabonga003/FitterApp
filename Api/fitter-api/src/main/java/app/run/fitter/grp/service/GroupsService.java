package app.run.fitter.grp.service;

import app.run.fitter.app.dto.GroupsDTO;
import reactor.core.publisher.Flux;

public interface GroupsService {
    Flux<GroupsDTO.GroupResponse> getAllActiveGroups();
}