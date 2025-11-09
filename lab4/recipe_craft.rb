#!/usr/bin/env ruby
# encoding: utf-8

# Модуль для конвертації одиниць вимірювання.
# Працює лише з сумісними типами (маса до маси, об'єм до об'єму).
module UnitConverter
  # Базові одиниці для кожної категорії
  BASE_UNITS = {
    g: :g,
    kg: :g,
    ml: :ml,
    l: :ml,
    pcs: :pcs
  }.freeze

  # Коефіцієнти для переведення в базову одиницю
  CONVERSION_RATES = {
    g: 1,
    kg: 1000,
    ml: 1,
    l: 1000,
    pcs: 1
  }.freeze

  # Головний метод для конвертації
  # Конвертує 'qty' з 'from_unit' в 'to_unit'
  def self.convert(qty, from_unit, to_unit)
    base_from = BASE_UNITS[from_unit]
    base_to = BASE_UNITS[to_unit]

    # Перевірка на сумісність (наприклад, не можна г -> мл)
    unless base_from == base_to
      raise ArgumentError, "Неможливо конвертувати #{from_unit} в #{to_unit}"
    end

    # Переводимо в базову одиницю
    base_qty = qty.to_f * CONVERSION_RATES[from_unit]

    # Переводимо з базової в цільову
    # (по суті, ділимо на коефіцієнт цільової одиниці)
    final_qty = base_qty / CONVERSION_RATES[to_unit]
    final_qty
  end

  # Допоміжний метод для переведення в базову одиницю
  def self.to_base_unit(qty, unit)
    base_unit = BASE_UNITS[unit]
    base_qty = qty.to_f * CONVERSION_RATES[unit]
    [base_qty, base_unit]
  end
end

# Клас для представлення інгредієнта
class Ingredient
  attr_reader :name, :base_unit, :calories_per_unit

  # base_unit - це :g, :ml, або :pcs
  # calories_per_unit - калорії за ЦЮ БАЗОВУ ОДИНИЦЮ
  def initialize(name, base_unit, calories_per_unit)
    @name = name
    @base_unit = base_unit
    @calories_per_unit = calories_per_unit.to_f
  end
end

# Клас для представлення рецепту
class Recipe
  attr_reader :name, :steps, :items

  # items - це масив хешів: [{ingredient:, qty:, unit:}]
  def initialize(name, steps, items)
    @name = name
    @steps = steps
    @items = items
  end

  # Рахує загальну потребу в інгредієнтах для рецепту
  # Повертає хеш {Ingredient => total_base_qty}
  def need
    needed_ingredients = Hash.new(0)
    @items.each do |item|
      ingredient = item[:ingredient]
      qty = item[:qty]
      unit = item[:unit]

      # Конвертуємо все в базові одиниці
      base_qty, _base_unit = UnitConverter.to_base_unit(qty, unit)

      # Додаємо до загальної потреби
      needed_ingredients[ingredient] += base_qty
    end
    needed_ingredients
  end
end

# Клас для комори (зберігання інгредієнтів)
class Pantry
  def initialize
    # Зберігаємо все в базових одиницях
    # Ключ - назва інгредієнта (String), значення - кількість (Float)
    @storage = Hash.new(0.0)
  end

  # Додавання інгредієнта в комору
  def add(name, qty, unit)
    base_qty, _base_unit = UnitConverter.to_base_unit(qty, unit)
    @storage[name] += base_qty
    puts "Додано в комору: #{name} - #{base_qty} #{_base_unit} (з #{qty} #{unit})"
  end

  # Перевірка наявності інгредієнта (в базових одиницях)
  def available_for(name)
    @storage[name]
  end
end

# Клас для планування
class Planner
  def plan(recipes, pantry, price_list)
    total_needs = Hash.new(0.0)
    all_ingredients = {} # Для зв'язки name -> Ingredient object

    # 1. Рахуємо загальну потребу для ВСІХ рецептів
    puts "--- Загальний список покупок ---"
    recipes.each do |recipe|
      puts "Для рецепту '#{recipe.name}':"
      recipe.need.each do |ingredient, base_qty|
        puts "  * #{ingredient.name}: #{base_qty.round(2)} #{ingredient.base_unit}"
        total_needs[ingredient] += base_qty
        all_ingredients[ingredient.name] = ingredient
      end
    end
    puts "--------------------------------"

    total_calories = 0.0
    total_cost = 0.0

    puts "\n--- Аналіз дефіциту та витрат ---"

    # 2. Перебираємо всі унікальні інгредієнти, що нам потрібні
    total_needs.each do |ingredient, needed_qty|
      name = ingredient.name
      base_unit = ingredient.base_unit

      # 3. Перевіряємо, що є в коморі
      have_qty = pantry.available_for(name)

      # 4. Рахуємо дефіцит
      deficit_qty = [0, needed_qty - have_qty].max

      # 5. Виводимо звіт по інгредієнту
      puts "#{name.ljust(8)}: " \
             "потрібно #{needed_qty.round(2)} / " \
             "є #{have_qty.round(2)} / " \
             "дефіцит #{deficit_qty.round(2)} #{base_unit}"

      # 6. Рахуємо калорії та вартість (на основі того, що ПОТРІБНО)
      price = price_list[name]
      calories_per_unit = ingredient.calories_per_unit

      unless price
        puts "  ! Увага: Немає ціни для '#{name}'"
        next
      end

      total_cost += needed_qty * price
      total_calories += needed_qty * calories_per_unit
    end

    # 7. Виводимо підсумки
    puts "--------------------------------"
    puts "Загальна калорійність: #{total_calories.round(2)} ккал"
    puts "Загальна вартість: #{total_cost.round(2)} грн"
  end
end


# ===================================================================
#                    🚀 ДЕМОНСТРАЦІЯ (demo.rb)
# ===================================================================

puts "===== 🍳 Ласкаво просимо до RecipeCraft! 🍝 =====\n\n"

# --- 1. Створюємо Інгредієнти (з калоріями за базу) ---
# Назви робимо унікальними
ing_egg = Ingredient.new("Яйце", :pcs, 72)
ing_milk = Ingredient.new("Молоко", :ml, 0.06)
ing_flour = Ingredient.new("Борошно", :g, 3.64)
ing_pasta = Ingredient.new("Паста", :g, 3.5)
ing_sauce = Ingredient.new("Соус", :ml, 0.2)
ing_cheese = Ingredient.new("Сир", :g, 4.0)

# --- 2. Заповнюємо Комору ---
puts "--- 🛒 Заповнення комори ---"
pantry = Pantry.new
pantry.add("Борошно", 1, :kg)   # 1 кг
pantry.add("Молоко", 0.5, :l)    # 0.5 л
pantry.add("Яйце", 6, :pcs)     # 6 шт (використовуємо ту саму назву, що й в Ingredient)
pantry.add("Паста", 300, :g)    # 300 г
pantry.add("Сир", 150, :g)     # 150 г
puts "------------------------------\n"

# --- 3. Встановлюємо Ціни (за базову од.) ---
price_list = {
  "Борошно" => 0.02,   # за 1 г
  "Молоко" => 0.015,  # за 1 мл
  "Яйце" => 6.0,     # за 1 шт
  "Паста" => 0.03,   # за 1 г
  "Соус" => 0.025,  # за 1 мл
  "Сир" => 0.08    # за 1 г
}

# --- 4. Створюємо Рецепти ---
recipe_omelette = Recipe.new(
  "Омлет",
  ["Змішати яйця, молоко та борошно", "Смажити на пательні"],
  [
    { ingredient: ing_egg, qty: 3, unit: :pcs },
    { ingredient: ing_milk, qty: 100, unit: :ml },
    { ingredient: ing_flour, qty: 20, unit: :g }
  ]
)

recipe_pasta = Recipe.new(
  "Паста з соусом",
  ["Відварити пасту", "Додати соус та сир"],
  [
    { ingredient: ing_pasta, qty: 200, unit: :g },
    { ingredient: ing_sauce, qty: 150, unit: :ml }, # Цього інгредієнта немає в коморі
    { ingredient: ing_cheese, qty: 50, unit: :g }
  ]
)

# --- 5. Запускаємо Планувальник ---
planner = Planner.new
planner.plan([recipe_omelette, recipe_pasta], pantry, price_list)

puts "\n\n===== 🍽️ Готово! ======"