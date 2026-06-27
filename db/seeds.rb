# frozen_string_literal: true

puts "Seeding database..."

StudioSetting::DEFAULTS.each do |key, value|
  StudioSetting.find_or_create_by!(key: key) do |setting|
    setting.value = value
  end
end
StudioSetting.set("studio_name", "Studio")
StudioSetting.set("studio_email", "hola@example.com")
StudioSetting.set("studio_phone", "+52 55 0000 0000")
StudioSetting.set("studio_address", "Calle Ejemplo 123, Ciudad")
puts "  ✓ Studio settings"

User.find_or_create_by!(email: "admin@example.com") do |u|
  u.first_name = "Admin"
  u.last_name = "User"
  u.password = "password"
  u.password_confirmation = "password"
  u.role = :admin
end

User.find_or_create_by!(email: "student@example.com") do |u|
  u.first_name = "Student"
  u.last_name = "Demo"
  u.password = "password"
  u.password_confirmation = "password"
  u.role = :student
end
puts "  ✓ Users"

SubscriptionPlan.find_or_create_by!(name: "Membresía Mensual") do |sp|
  sp.price = 499.00
  sp.interval = "monthly"
  sp.description = "Acceso a contenido exclusivo para miembros."
end

SubscriptionPlan.find_or_create_by!(name: "Membresía Anual") do |sp|
  sp.price = 4990.00
  sp.interval = "annual"
  sp.description = "Acceso a contenido exclusivo todo el año. Ahorra 17%."
end
puts "  ✓ Subscription plans"

Product.find_or_create_by!(slug: "playera-studio") do |p|
  p.name = "Playera Studio"
  p.sku = "STD-TEE-001"
  p.kind = "physical"
  p.price = 450.00
  p.stock_quantity = 25
  p.requires_shipping = true
  p.shipping_cost = 99.00
  p.description = "Playera de algodón orgánico, corte unisex. Disponible en talla M."
  p.active = true
end
puts "  ✓ Products"

Event.find_or_create_by!(title: "Taller de bienvenida") do |e|
  e.description = "Una sesión introductoria para conocer la comunidad. Incluye snacks y bebidas."
  e.date = 2.weeks.from_now.to_date
  e.start_time = Time.zone.parse("18:00")
  e.end_time = Time.zone.parse("20:00")
  e.location = "Calle Ejemplo 123, Ciudad"
  e.capacity = 30
  e.spots_remaining = 30
  e.price = 250.00
  e.published = true
end
puts "  ✓ Events"

puts "\nSeeding complete!"
puts "  Admin:   admin@example.com / password"
puts "  Student: student@example.com / password"
