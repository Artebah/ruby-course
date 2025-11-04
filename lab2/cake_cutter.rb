class CakeCutter
  # Ініціалізуємо клас, передавши йому рядок з пирогом
  def initialize(cake_string)
    # Нормалізуємо вхідні дані: прибираємо зайві пробіли,
    # і створюємо масив рядків
    @cake_arr = cake_string.strip.split("\n")
    @height = @cake_arr.length
    @width = @cake_arr[0].length

    # Рахуємо родзинки (враховуємо і латинську 'o' і кириличну 'о')
    @total_raisins = count_raisins(0, 0, @height, @width)

    # Якщо родзинок 0 або площа не ділиться націло, рішення неможливе
    if @total_raisins == 0 || (@height * @width) % @total_raisins != 0
      raise "Неможливо розрізати: некоректна конфігурація пирога."
    end

    # Площа, яка має бути у кожного шматка
    @target_area = (@height * @width) / @total_raisins

    # Кеш для зберігання результатів (мемоізація)
    @memo = {}
  end

  # Публічний метод для запуску розв'язання
  def solve
    # Знаходимо всі можливі варіанти розрізання
    all_solutions = find_cuts(0, 0, @height, @width)

    if all_solutions.empty?
      puts "Рішень не знайдено!"
      return nil
    end

    # Вибираємо найкраще рішення за критерієм:
    # "найбільша ширина першого елемента масиву"
    best_solution = all_solutions.max_by do |solution_arr|
      # solution_arr - це один з варіантів, масив шматків-рядків
      # solution_arr[0] - перший шматок
      # .split("\n", 2)[0] - беремо перший рядок цього шматка
      # .length - це і є його ширина
      first_piece_string = solution_arr[0]
      first_piece_width = first_piece_string.split("\n", 2)[0].length
      first_piece_width
    end

    best_solution
  end

  private

  # Рекурсивна функція пошуку розрізів
  # r, c - верхній лівий кут поточного шматка
  # h, w - висота та ширина поточного шматка
  # Повертає: масив рішень. Кожне рішення - це масив шматків-рядків.
  # Наприклад: [ [piece1, piece2], [piece1_alt, piece2_alt] ]
  def find_cuts(r, c, h, w)
    # Ключ для кешу
    cache_key = [r, c, h, w]
    # Якщо ми вже рахували для такого шматка, повертаємо результат з кешу
    return @memo[cache_key] if @memo.key?(cache_key)

    # Рахуємо родзинки в поточному шматку
    n_raisins = count_raisins(r, c, h, w)

    # --- Базовий випадок рекурсії ---
    # Якщо в шматку 1 родзинка
    if n_raisins == 1
      # Перевіряємо, чи його площа відповідає цільовій
      if h * w == @target_area
        # Це коректний фінальний шматок.
        # Повертаємо масив, що містить одне рішення,
        # яке є масивом з одного цього шматка.
        piece_str = get_piece_string(r, c, h, w)
        return @memo[cache_key] = [ [piece_str] ]
      else
        # 1 родзинка, але площа не та. Це тупиковий шлях.
        return @memo[cache_key] = []
      end
    end

    # --- Рекурсивний крок ---
    # Якщо родзинок > 1, пробуємо різати
    all_solutions_for_this_piece = []

    # 1. Пробуємо всі горизонтальні розрізи
    (1...h).each do |cut_h| # cut_h - висота верхнього шматка
      n_a = count_raisins(r, c, cut_h, w) # Родзинки у верхньому
      n_b = n_raisins - n_a                # Родзинки у нижньому

      # Перевіряємо, чи розріз валідний:
      # 1. Обидва шматки мають мати родзинки
      # 2. Площа верхнього шматка має дорівнювати (кількість родзинок * цільову площу)
      if n_a > 0 && n_b > 0 && (cut_h * w) == n_a * @target_area
        # Рекурсивно шукаємо рішення для верхнього та нижнього шматків
        solutions_a = find_cuts(r, c, cut_h, w)
        solutions_b = find_cuts(r + cut_h, c, h - cut_h, w)

        # Комбінуємо всі рішення: кожне рішення з А + кожне рішення з Б
        solutions_a.each do |sol_a|
          solutions_b.each do |sol_b|
            all_solutions_for_this_piece << (sol_a + sol_b)
          end
        end
      end
    end

    # 2. Пробуємо всі вертикальні розрізи
    (1...w).each do |cut_w| # cut_w - ширина лівого шматка
      n_a = count_raisins(r, c, h, cut_w) # Родзинки у лівому
      n_b = n_raisins - n_a                # Родзинки у правому

      # Перевіряємо валідність розрізу
      if n_a > 0 && n_b > 0 && (h * cut_w) == n_a * @target_area
        # Рекурсивно шукаємо рішення
        solutions_a = find_cuts(r, c, h, cut_w)
        solutions_b = find_cuts(r, c + cut_w, h, w - cut_w)

        # Комбінуємо
        solutions_a.each do |sol_a|
          solutions_b.each do |sol_b|
            all_solutions_for_this_piece << (sol_a + sol_b)
          end
        end
      end
    end

    # Зберігаємо результат в кеш і повертаємо його
    @memo[cache_key] = all_solutions_for_this_piece
  end

  # Допоміжний метод: рахує родзинки в прямокутнику
  def count_raisins(r, c, h, w)
    count = 0
    (r...r + h).each do |row_idx|
      (c...c + w).each do |col_idx|
        # Перевіряємо обидва символи 'o' (Eng) та 'о' (Ukr)
        char = @cake_arr[row_idx][col_idx]
        count += 1 if char == 'o' || char == 'о'
      end
    end
    count
  end

  # Допоміжний метод: "вирізає" шматок
  def get_piece_string(r, c, h, w)
    @cake_arr[r ... r + h].map { |row_str| row_str[c ... c + w] }.join("\n")
  end
end

# --- Функція для гарного друку результату ---
def print_solution(solution)
  if solution.nil?
    puts "Рішення не знайдено."
    return
  end

  puts "["
  solution.each_with_index do |piece, index|
    puts "  // Шматок #{index + 1}"
    # Додаємо відступи для кожного рядка шматка
    piece.split("\n").each do |line|
      puts "  #{line}"
    end
    puts "  ," if index < solution.length - 1
  end
  puts "]"
  puts "-" * 20
end

# --- ТЕСТУВАННЯ ---

puts "--- Приклад 1 (з завдання) ---"
cake1_str = "........\n..o.....\n...o....\n........"
# → 2 родзинки, площа 32, площа шматка = 16
# Очікуваний результат: 2 шматки 2х8
cutter1 = CakeCutter.new(cake1_str)
solution1 = cutter1.solve
print_solution(solution1)


puts "--- Приклад 2 (горизонтальний виграє) ---"
cake2_str = ".о......\n......о.\n....о...\n..о....."
# → 4 родзинки, площа 32, площа шматка = 8
# Можливі рішення: 4 шматки 1x8 (ширина 8)
#                   4 шматки 4x2 (ширина 2)
# Має обрати 1x8
cutter2 = CakeCutter.new(cake2_str)
solution2 = cutter2.solve
print_solution(solution2)


puts "--- Приклад 3 (складний) ---"
cake3_str = ".о.о....\n........\n....о...\n........\n.....о..\n........"
# → 4 родзинки, площа 48, площа шматка = 12
cutter3 = CakeCutter.new(cake3_str)
solution3 = cutter3.solve
print_solution(solution3)