# frozen_string_literal: true

require_relative "ua_phone_validator/version"

module UaPhoneValidator
  class Error < StandardError; end

  # Головний regex:
  # ^(380|0) - Починається з 380 (міжнародний) АБО 0 (національний)
  # (50|66|95|99|...) - Далі йдуть відомі коди операторів
  # \d{7}$ - Завершується 7-ма цифрами
  # (Ми використовуємо \A і \z замість ^ і $ для перевірки всього рядка)
  UA_PHONE_REGEX = /\A(380|0)(50|66|95|99|67|68|96|97|98|63|73|93|91|92|94)\d{7}\z/

  # 1. Метод для валідації
  def self.valid?(phone_number)
    # "Очищуємо" номер від зайвих символів
    sanitized = sanitize(phone_number)
    
    # Перевіряємо за допомогою regex
    !!(sanitized =~ UA_PHONE_REGEX)
  end

  # 2. Форматування в E.164 (+380...)
  def self.format_e164(phone_number)
    return nil unless valid?(phone_number) # Повертаємо nil, якщо номер невалідний
    
    sanitized = sanitize(phone_number)
    
    # Якщо номер починається з "0", замінюємо на "+380"
    if sanitized.start_with?("0")
      "+38" + sanitized
    else # Інакше (він уже 380...), просто додаємо "+"
      "+" + sanitized
    end
  end

  # 3. Форматування в національний (0...)
  def self.format_national(phone_number)
    return nil unless valid?(phone_number)
    
    sanitized = sanitize(phone_number)
    
    # Якщо номер починається з "380", замінюємо на "0"
    if sanitized.start_with?("380")
      sanitized.sub("380", "0")
    else # Інакше (він уже 0...), просто повертаємо
      sanitized
    end
  end

  private

  # Допоміжний метод для очищення
  def self.sanitize(phone_number)
    # Залишаємо тільки цифри
    phone_number.to_s.gsub(/\D/, '')
  end
end