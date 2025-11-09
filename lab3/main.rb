# frozen_string_literal: true

require_relative 'duplicate_scanner'

# --- КОНФІГУРАЦІЯ ---

# 1. Шлях для сканування (яку папку перевіряти)
# ПОПЕРЕДЖЕННЯ: Не вказуйте C:/, сканування може зайняти ДУЖЕ багато часу.
TARGET_DIRECTORY = 'C:\Users\Admin\Coding\University\Ruby/lab3/test_data'

# 2. Шлях для збереження звітів (куди покласти .json та .csv)
#    ВАШ ШЛЯХ: 'C:\Users\Admin\Coding\University\Ruby\lab3'
#    У Ruby краще використовувати прямі слеші:
OUTPUT_DIRECTORY = 'C:/Users/Admin/Coding/University/Ruby/lab3/scan_info'

# --- КІНЕЦЬ КОНФІГУРАЦІЇ ---

# --- Логіка запуску ---
def run_scanner
  # Перевірка 1: чи існує каталог для сканування
  unless Dir.exist?(TARGET_DIRECTORY)
    puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    puts "!! ПОМИЛКА: Каталог для сканування '#{TARGET_DIRECTORY}' не знайдено."
    puts "!! Відкрийте 'main.rb' і змініть 'TARGET_DIRECTORY'."
    puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    exit
  end

  # Перевірка 2: чи існує каталог для збереження звітів
  unless Dir.exist?(OUTPUT_DIRECTORY)
    puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    puts "!! ПОМИЛКА: Каталог для збереження '#{OUTPUT_DIRECTORY}' не знайдено."
    puts "!! Будь ласка, створіть цю папку вручну,"
    puts "!! або виправте шлях 'OUTPUT_DIRECTORY' у файлі 'main.rb'."
    puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    exit
  end

  # Перевірка, чи шлях не змінено
  if TARGET_DIRECTORY == '/path/to/your/directory'
    puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    puts "!! УВАГА: Ви не змінили 'TARGET_DIRECTORY' для сканування."
    puts "!! Відкрийте 'main.rb' і вкажіть реальний каталог."
    puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    exit
  end

  puts "Запуск сканера дублікатів для: #{TARGET_DIRECTORY}"
  puts "Звіти буде збережено у: #{OUTPUT_DIRECTORY}"
  start_time = Time.now

  scanner = DuplicateScanner.new
  # Передаємо обидва шляхи до сканера
  scanner.scan(TARGET_DIRECTORY, output_dir: OUTPUT_DIRECTORY)

  end_time = Time.now
  duration = (end_time - start_time).round(2)

  puts "\n--- Статистика сканування ---"
  puts "Загальний час: #{duration} сек."
  puts "Всього проскановано файлів: #{scanner.report[:scanned_files]}"
  puts "Знайдено груп дублікатів: #{scanner.report[:groups].length}"

  total_saved_bytes = scanner.report[:groups].sum { |g| g[:saved_if_dedup_bytes] }
  total_saved_mb = (total_saved_bytes / (1024.0 * 1024.0)).round(2)
  puts "Можлива економія місця (якщо видалити всі копії): #{total_saved_mb} MB"
end

# Запускаємо головну функцію
run_scanner