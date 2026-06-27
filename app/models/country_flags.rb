# Mapa de selecciones (nombre en español) → emoji de bandera, para mostrar
# banderas sin depender de assets. Tolerante a alias/acentos al buscar.
module CountryFlags
  FLAGS = {
    # Anfitriones
    "México" => "🇲🇽", "Estados Unidos" => "🇺🇸", "Canadá" => "🇨🇦",
    # Sudamérica
    "Argentina" => "🇦🇷", "Brasil" => "🇧🇷", "Uruguay" => "🇺🇾", "Colombia" => "🇨🇴",
    "Ecuador" => "🇪🇨", "Paraguay" => "🇵🇾", "Perú" => "🇵🇪", "Chile" => "🇨🇱",
    "Bolivia" => "🇧🇴", "Venezuela" => "🇻🇪",
    # Europa
    "Francia" => "🇫🇷", "España" => "🇪🇸", "Inglaterra" => "🏴󠁧󠁢󠁥󠁮󠁧󠁿", "Portugal" => "🇵🇹",
    "Países Bajos" => "🇳🇱", "Bélgica" => "🇧🇪", "Alemania" => "🇩🇪", "Italia" => "🇮🇹",
    "Croacia" => "🇭🇷", "Suiza" => "🇨🇭", "Dinamarca" => "🇩🇰", "Polonia" => "🇵🇱",
    "Serbia" => "🇷🇸", "Noruega" => "🇳🇴", "Austria" => "🇦🇹", "Turquía" => "🇹🇷",
    "Ucrania" => "🇺🇦", "Suecia" => "🇸🇪", "Escocia" => "🏴󠁧󠁢󠁳󠁣󠁴󠁿", "Gales" => "🏴󠁧󠁢󠁷󠁬󠁳󠁿",
    "Hungría" => "🇭🇺", "Chequia" => "🇨🇿", "Eslovenia" => "🇸🇮", "Eslovaquia" => "🇸🇰",
    "Grecia" => "🇬🇷", "Rumania" => "🇷🇴", "Irlanda" => "🇮🇪",
    # África
    "Senegal" => "🇸🇳", "Marruecos" => "🇲🇦", "Ghana" => "🇬🇭", "Camerún" => "🇨🇲",
    "Egipto" => "🇪🇬", "Nigeria" => "🇳🇬", "Argelia" => "🇩🇿", "Túnez" => "🇹🇳",
    "Costa de Marfil" => "🇨🇮", "Sudáfrica" => "🇿🇦", "Cabo Verde" => "🇨🇻", "Malí" => "🇲🇱",
    # Asia / Oceanía
    "Japón" => "🇯🇵", "Corea del Sur" => "🇰🇷", "Australia" => "🇦🇺", "Irán" => "🇮🇷",
    "Arabia Saudita" => "🇸🇦", "Catar" => "🇶🇦", "Uzbekistán" => "🇺🇿", "Jordania" => "🇯🇴",
    "Nueva Zelanda" => "🇳🇿",
    # Concacaf
    "Costa Rica" => "🇨🇷", "Panamá" => "🇵🇦", "Jamaica" => "🇯🇲", "Honduras" => "🇭🇳",
    "Haití" => "🇭🇹", "Curazao" => "🇨🇼"
  }.freeze

  # Alias frecuentes (clave normalizada) → nombre canónico
  ALIASES = {
    "corea" => "Corea del Sur", "corea del sur" => "Corea del Sur", "south korea" => "Corea del Sur",
    "eeuu" => "Estados Unidos", "ee uu" => "Estados Unidos", "usa" => "Estados Unidos", "estados unidos de america" => "Estados Unidos",
    "holanda" => "Países Bajos", "paises bajos" => "Países Bajos",
    "republica checa" => "Chequia", "chequia" => "Chequia",
    "qatar" => "Catar", "costa marfil" => "Costa de Marfil"
  }.freeze

  NAMES = FLAGS.keys.sort.freeze

  def self.emoji(name)
    return nil if name.blank?

    FLAGS[name] || FLAGS[canonical(name)]
  end

  def self.canonical(name)
    key = normalize(name)
    ALIASES[key] || FLAGS.keys.find { |k| normalize(k) == key }
  end

  def self.normalize(str)
    str.to_s.unicode_normalize(:nfkd).gsub(/\p{Mn}/, "").downcase.strip
  end
end
