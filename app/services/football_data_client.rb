require "net/http"
require "json"

# Cliente mínimo para football-data.org (v4). Aislado a propósito: es la única
# parte que toca la red, así que la lógica de parseo/mapeo vive en
# ResultsSyncService (y sí se testea). Requiere ENV["FOOTBALL_DATA_API_TOKEN"].
class FootballDataClient
  BASE = "https://api.football-data.org/v4".freeze
  COMPETITION = "WC".freeze # FIFA World Cup

  class Error < StandardError; end

  def initialize(token: ENV["FOOTBALL_DATA_API_TOKEN"])
    @token = token
  end

  def configured?
    @token.present?
  end

  # Todos los partidos del Mundial (grupos + eliminación) con marcadores/estado.
  def world_cup_matches
    get("/competitions/#{COMPETITION}/matches")
  end

  private

  def get(path)
    raise Error, "FOOTBALL_DATA_API_TOKEN no configurado" unless configured?

    uri = URI("#{BASE}#{path}")
    request = Net::HTTP::Get.new(uri)
    request["X-Auth-Token"] = @token

    response = http(uri).request(request)
    unless response.is_a?(Net::HTTPSuccess)
      raise Error, "football-data #{response.code}: #{response.body.to_s.truncate(200)}"
    end

    JSON.parse(response.body)
  rescue Net::OpenTimeout, Net::ReadTimeout, SocketError => e
    raise Error, "conexión fallida: #{e.message}"
  end

  # Respeta un proxy de salida si el entorno lo define (HTTPS_PROXY).
  def http(uri)
    proxy = ENV["HTTPS_PROXY"] || ENV["https_proxy"]
    client =
      if proxy.present?
        p = URI(proxy)
        Net::HTTP.new(uri.host, uri.port, p.host, p.port, p.user, p.password)
      else
        Net::HTTP.new(uri.host, uri.port)
      end
    client.use_ssl = uri.scheme == "https"
    client.open_timeout = 10
    client.read_timeout = 15
    client
  end
end
