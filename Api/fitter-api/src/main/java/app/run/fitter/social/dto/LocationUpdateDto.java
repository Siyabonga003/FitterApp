package app.run.fitter.social.dto;

public record LocationUpdateDto(
        double latitude,
        double longitude,
        double pace,
        double distance,
        boolean sharingLive
) {}