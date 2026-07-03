package app.run.fitter.config;

import app.run.fitter.activity.entity.JsonbValue;
import io.r2dbc.postgresql.codec.Json;
import io.r2dbc.spi.ConnectionFactory;
import io.r2dbc.spi.ConnectionFactoryOptions;
import lombok.AllArgsConstructor;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.r2dbc.ConnectionFactoryBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.convert.converter.Converter;
import org.springframework.data.convert.ReadingConverter;
import org.springframework.data.convert.WritingConverter;
import org.springframework.data.r2dbc.config.AbstractR2dbcConfiguration;
import org.springframework.data.r2dbc.repository.config.EnableR2dbcRepositories;
import org.springframework.r2dbc.connection.R2dbcTransactionManager;
import org.springframework.transaction.ReactiveTransactionManager;

import java.util.List;

@Configuration
@EnableR2dbcRepositories
@AllArgsConstructor
public class DatabaseConfig extends AbstractR2dbcConfiguration {

    private final ConfigProperties configProperties;

    @Override
    @Bean
    public ConnectionFactory connectionFactory() {
        ConnectionFactoryBuilder factoryBuilder =
                ConnectionFactoryBuilder.withUrl(configProperties.getDbUrl());

        return ConnectionFactoryBuilder.withOptions(factoryBuilder.buildOptions()
                .mutate()
                .option(ConnectionFactoryOptions.USER, configProperties.getDbUsername())
                .option(ConnectionFactoryOptions.PASSWORD, configProperties.getDbPassword()))
                .build();
    }

    @Bean
    public ReactiveTransactionManager transactionManager(
            @Qualifier("connectionFactory") ConnectionFactory connectionFactory) {
        return new R2dbcTransactionManager(connectionFactory);
    }

    @Override
    protected List<Object> getCustomConverters() {
        return List.of(
                new JsonToJsonbValueConverter(),
                new JsonbValueToJsonConverter()
        );
    }

    @ReadingConverter
    static class JsonToJsonbValueConverter implements Converter<Json, JsonbValue> {
        @Override
        public JsonbValue convert(Json source) {
            return JsonbValue.of(source.asString());
        }
    }

    @WritingConverter
    static class JsonbValueToJsonConverter implements Converter<JsonbValue, Json> {
        @Override
        public Json convert(JsonbValue source) {
            return Json.of(source.value());
        }
    }
}