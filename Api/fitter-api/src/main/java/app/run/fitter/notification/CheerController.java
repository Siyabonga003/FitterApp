package app.run.fitter.notification;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.ReactiveSecurityContextHolder;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Mono;

@RestController
@RequestMapping("/api/cheer")
public class CheerController {

    private final CheerService cheerService;

    public CheerController(CheerService cheerService) {
        this.cheerService = cheerService;
    }

    @PostMapping("/{targetUserId}")
    public Mono<ResponseEntity<Void>> sendCheer(@PathVariable String targetUserId) {
        return ReactiveSecurityContextHolder.getContext()
                .map(SecurityContext::getAuthentication)
                .map(auth -> auth.getName())
                .flatMap(senderId ->
                        cheerService.sendCheer(senderId, targetUserId)
                )
                .thenReturn(ResponseEntity.<Void>ok().build());
    }
}