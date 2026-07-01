package app.run.fitter.app.controller;

import app.run.fitter.app.dto.GroupsDTO;
import app.run.fitter.grp.service.GroupsService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Flux;

@RestController
@RequestMapping("/api/v1/groups")
@RequiredArgsConstructor
public class GroupsController {

    private final GroupsService groupsService;

    @GetMapping
    public Flux<GroupsDTO.GroupResponse> fetchAllGroups() {
        return groupsService.getAllActiveGroups();
    }
}