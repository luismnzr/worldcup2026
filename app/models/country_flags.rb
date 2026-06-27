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

  # Alias frecuentes (clave normalizada) → nombre canónico. Incluye los nombres
  # en inglés que devuelven las APIs de resultados (football-data.org, etc.).
  ALIASES = {
    # Español / coloquiales
    "corea" => "Corea del Sur", "corea del sur" => "Corea del Sur",
    "eeuu" => "Estados Unidos", "ee uu" => "Estados Unidos", "usa" => "Estados Unidos", "estados unidos de america" => "Estados Unidos",
    "holanda" => "Países Bajos", "paises bajos" => "Países Bajos",
    "republica checa" => "Chequia",
    "qatar" => "Catar", "costa marfil" => "Costa de Marfil",
    # Inglés (APIs)
    "mexico" => "México", "united states" => "Estados Unidos", "usmnt" => "Estados Unidos", "canada" => "Canadá",
    "brazil" => "Brasil", "spain" => "España", "england" => "Inglaterra", "netherlands" => "Países Bajos",
    "belgium" => "Bélgica", "germany" => "Alemania", "italy" => "Italia", "croatia" => "Croacia",
    "switzerland" => "Suiza", "denmark" => "Dinamarca", "poland" => "Polonia", "serbia" => "Serbia",
    "norway" => "Noruega", "austria" => "Austria", "turkey" => "Turquía", "turkiye" => "Turquía",
    "ukraine" => "Ucrania", "sweden" => "Suecia", "scotland" => "Escocia", "wales" => "Gales",
    "hungary" => "Hungría", "czechia" => "Chequia", "czech republic" => "Chequia", "slovenia" => "Eslovenia",
    "slovakia" => "Eslovaquia", "greece" => "Grecia", "romania" => "Rumania", "ireland" => "Irlanda",
    "republic of ireland" => "Irlanda", "france" => "Francia", "portugal" => "Portugal",
    "south korea" => "Corea del Sur", "korea republic" => "Corea del Sur", "japan" => "Japón",
    "iran" => "Irán", "ir iran" => "Irán", "saudi arabia" => "Arabia Saudita", "uzbekistan" => "Uzbekistán",
    "jordan" => "Jordania", "australia" => "Australia", "new zealand" => "Nueva Zelanda",
    "senegal" => "Senegal", "morocco" => "Marruecos", "ghana" => "Ghana", "cameroon" => "Camerún",
    "egypt" => "Egipto", "nigeria" => "Nigeria", "algeria" => "Argelia", "tunisia" => "Túnez",
    "ivory coast" => "Costa de Marfil", "cote d'ivoire" => "Costa de Marfil", "south africa" => "Sudáfrica",
    "cape verde" => "Cabo Verde", "cabo verde" => "Cabo Verde", "mali" => "Malí",
    "costa rica" => "Costa Rica", "panama" => "Panamá", "jamaica" => "Jamaica", "honduras" => "Honduras",
    "haiti" => "Haití", "curacao" => "Curazao", "peru" => "Perú", "bolivia" => "Bolivia",
    "venezuela" => "Venezuela", "paraguay" => "Paraguay", "chile" => "Chile", "colombia" => "Colombia",
    "ecuador" => "Ecuador", "uruguay" => "Uruguay", "argentina" => "Argentina"
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
