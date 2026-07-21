package app.run.fitter.file.dto;

import org.springframework.core.io.buffer.DataBuffer;

public record FileContent(DataBuffer data, String mimeType) {}