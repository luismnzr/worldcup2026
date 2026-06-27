redis_config = {
  url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"),
  ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
}

Sidekiq.configure_server do |config|
  config.redis = redis_config

  # Sincroniza resultados del Mundial cada 10 min. Se registra siempre; el job
  # hace no-op si aún no hay API key (ENV o Settings), así que pegar la key en
  # el admin lo activa sin reiniciar. La captura manual sigue siendo el override.
  config.on(:startup) do
    if defined?(Sidekiq::Cron::Job)
      Sidekiq::Cron::Job.create(
        name: "Resultados Mundial — cada 10 min",
        cron: "*/10 * * * *",
        class: "ResultsSyncJob"
      )
    end
  end
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end
