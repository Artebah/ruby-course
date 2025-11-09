# Підключаємо наш гем напряму з директорії lib
require_relative 'lib/ua_phone_validator'

# Список телефонів для демонстрації
phones = [
  "0971234567",
  "+380(67)123-45-67",
  "38050-123-45-67",
  "063 123 45 67",
  "12345",          # невалідний
  "0111234567"      # невалідний
]

puts "--- Демонстрація роботи гема UaPhoneValidator ---"

phones.each do |phone|
  puts "\nТелефон: #{phone}"
  
  if UaPhoneValidator.valid?(phone)
    puts "  -> Статус: ВАЛІДНИЙ"
    puts "  -> E.164: #{UaPhoneValidator.format_e164(phone)}"
    puts "  -> Нац.: #{UaPhoneValidator.format_national(phone)}"
  else
    puts "  -> Статус: НЕВАЛІДНИЙ"
  end
end