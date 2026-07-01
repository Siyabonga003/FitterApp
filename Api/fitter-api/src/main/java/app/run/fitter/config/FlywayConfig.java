package app.run.fitter.config;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.flywaydb.core.Flyway;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.event.EventListener;

@Configuration
@Slf4j
@RequiredArgsConstructor
public class FlywayConfig {
    private final ConfigProperties configProperties;

    @EventListener(ApplicationReadyEvent.class)
    public void migrate() {
        log.info("starting migrations...");

        try {
            Flyway flyway = Flyway.configure()
                    .dataSource(configProperties.getFlywayUrl(), configProperties.getFlywayUser(), configProperties.getFlywayPassword())
                    .locations(configProperties.getFlywayLocations())
                    .baselineOnMigrate(true)
                    .validateOnMigrate(true)
                    .cleanDisabled(true)
                    .load();

            flyway.migrate();

            log.info("migrations completed successfully");
        } catch (Exception e) {
            log.error("Error running migrations: ", e);

            throw new RuntimeException("Error running migrations: " + e.getMessage());
        }
    }
}
