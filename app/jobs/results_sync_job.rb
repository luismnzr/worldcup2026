# Sincroniza resultados desde football-data.org. Lo dispara sidekiq-cron de
# forma recurrente y también el botón "Sincronizar" del admin. No-op si falta
# la API key, para que el resto de la app funcione sin configurarla.
class ResultsSyncJob < ApplicationJob
  queue_as :default

  def perform
    client = FootballDataClient.new
    return unless client.configured?

    summary = ResultsSyncService.call(client.world_cup_matches)
    Rails.logger.info "[ResultsSync] aplicados=#{summary.applied} sin_resolver=#{summary.unresolved.size}"
    summary
  rescue FootballDataClient::Error => e
    Rails.logger.warn "[ResultsSync] #{e.message}"
    nil
  end
end
