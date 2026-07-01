package app.run.fitter.app.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.UUID;

public class GroupsDTO {

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class GroupResponse {
        private UUID id;
        private String name;
        private long memberCount;
        private String progressLabel;
        private double progressValue;
    }
}