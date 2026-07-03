package app.run.fitter.activity.entity;

public record JsonbValue(String value) {
    public static JsonbValue of(String value) {
        return value != null ? new JsonbValue(value) : null;
    }

    @Override
    public String toString() {
        return value;
    }
}