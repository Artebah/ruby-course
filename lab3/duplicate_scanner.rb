# frozen_string_literal: true

require 'find'
require 'digest'
require 'json'
require 'csv'
require 'set'

# Клас для сканування та знаходження дублікатів файлів у заданому каталозі.
class DuplicateScanner
  attr_reader :report, :scanned_files_count

  def initialize
    @scanned_files_count = 0
    @report = { scanned_files: 0, groups: [] }
    @progress_counter = 0
  end

  # Головний метод для запуску сканування
  #
  # @param root_dir [String] Шлях до каталогу, який потрібно просканувати
  # @param output_dir [String] Шлях до каталогу, куди зберегти звіти
  def scan(root_dir, output_dir: '.')
    puts "1. Починаю збір файлів у: #{root_dir}..."
    files_by_size = collect_files_by_size(root_dir)

    puts "\nЗнайдено #{@scanned_files_count} файлів."
    puts "2. Пошук потенційних дублікатів (файлів з однаковим розміром)..."
    potential_groups = files_by_size.values.select { |files| files.length > 1 }

    if potential_groups.empty?
      puts "Потенційних дублікатів не знайдено."
      @report[:scanned_files] = @scanned_files_count
      write_reports(output_dir) # Все одно записуємо порожній звіт
      return
    end

    puts "Знайдено #{potential_groups.length} груп файлів з однаковим розміром."
    puts "3. Запуск побайтової перевірки (через хешування)..."

    final_groups = confirm_duplicates_by_hash(potential_groups)

    puts "\n4. Формування звіту..."
    build_report(final_groups)

    write_reports(output_dir) # Передаємо шлях для збереження
    puts "5. Готово! Звіти збережено у каталозі: #{output_dir}"
  end

  private

  # Фаза 1: Збирає всі файли, групуючи їх за розміром.
  def collect_files_by_size(root_dir)
    files_by_size = {}
    @scanned_files_count = 0

    Find.find(root_dir) do |path|
      unless File.readable?(path)
        puts "Попередження: Немає доступу до '#{path}'. Пропускаю."
        Find.prune
      end

      next unless File.file?(path)

      @scanned_files_count += 1
      print "Зібрано файлів: #{@scanned_files_count}\r"

      begin
        size = File.size(path)
        next if size.zero?

        (files_by_size[size] ||= []) << path
      rescue Errno::ENOENT
        puts "Попередження: Файл '#{path}' не знайдено (можливо, видалено). Пропускаю."
      end
    end
    files_by_size
  end

  # Фаза 2: Порівнює файли з однаковим розміром побайтово (через хеш SHA256)
  def confirm_duplicates_by_hash(potential_groups)
    final_groups = []
    total_groups = potential_groups.length
    @progress_counter = 0

    potential_groups.each do |group|
      @progress_counter += 1
      print_progress(group)

      files_by_hash = {}
      group.each do |file_path|
        begin
          hash = Digest::SHA256.file(file_path).hexdigest
          (files_by_hash[hash] ||= []) << file_path
        rescue Errno::EACCES, Errno::ENOENT => e
          puts "\nПопередження: Не вдалося прочитати файл '#{file_path}'. Пропускаю. (Помилка: #{e.message})"
        end
      end

      files_by_hash.values.each do |files|
        final_groups << files if files.length > 1
      end
    end
    final_groups
  end

  # Фаза 3: Будує фінальний об'єкт звіту
  def build_report(final_groups)
    @report[:scanned_files] = @scanned_files_count

    final_groups.each do |group|
      size_bytes = File.size(group.first)
      saved_if_dedup_bytes = size_bytes * (group.length - 1)

      @report[:groups] << {
        size_bytes: size_bytes,
        saved_if_dedup_bytes: saved_if_dedup_bytes,
        files: group.sort
      }
    end

    @report[:groups].sort_by! { |g| -g[:saved_if_dedup_bytes] }
  end

  # Фаза 4: Записує звіти у JSON та CSV за вказаним шляхом
  def write_reports(output_dir)
    # Створюємо повні шляхи до файлів
    json_path = File.join(output_dir, 'duplicates.json')
    csv_path = File.join(output_dir, 'duplicates.csv')

    # Запис JSON
    File.write(json_path, JSON.pretty_generate(@report))

    # Запис CSV
    CSV.open(csv_path, 'wb') do |csv|
      csv << ['group_id', 'size_bytes', 'saved_if_dedup_bytes', 'file_path']

      @report[:groups].each_with_index do |group, index|
        group_id = index + 1
        group[:files].each do |file_path|
          csv << [group_id, group[:size_bytes], group[:saved_if_dedup_bytes], file_path]
        end
      end
    end
  end

  # Допоміжний метод для виводу прогресу
  def print_progress(group)
    total_groups = @report.length
    size_mb = (File.size(group.first) / (1024.0 * 1024.0)).round(2)
    print "Перевірка групи #{@progress_counter}/#{total_groups} (Розмір: #{size_mb} MB)...\r"
    $stdout.flush
  end
end