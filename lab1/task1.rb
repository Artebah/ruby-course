# Метод word_stats(text)
# 1. text.scan(/\w+/) - знаходить всі послідовності "слів" (літери, цифри, _)
# 2. words.length - загальна кількість
# 3. words.max_by(&:length) - знаходить слово з максимальною довжиною
# 4. words.map(&:downcase).uniq.length - переводить всі слова в нижній регістр,
#                                         знаходить унікальні і рахує їх кількість.

def word_stats(text)
  # Використовуємо .scan(/\w+/) для отримання чистого списку слів
  # без знаків пунктуації.
  words = text.scan(/\w+/)

  # Перевірка, чи текст не порожній
  if words.empty?
    puts "У тексті не знайдено слів."
    return
  end

  # 1. Підрахунок кількості слів
  total_count = words.length

  # 2. Пошук найдовшого слова
  longest_word = words.max_by { |word| word.length }
  # Або коротший синтаксис: longest_word = words.max_by(&:length)

  # 3. Підрахунок унікальних слів (без урахування регістру)
  unique_count = words.map { |word| word.downcase }.uniq.length
  # Або коротший синтаксис: unique_count = words.map(&:downcase).uniq.length

  # Виведення результату
  puts "--- Статистика ---"
  puts "→ #{total_count} слів, найдовше: #{longest_word}, унікальних: #{unique_count}"
end

# --- Демонстрація Завдання 1 ---
puts "Введіть рядок тексту для аналізу:"
user_text = gets.chomp

word_stats(user_text)
