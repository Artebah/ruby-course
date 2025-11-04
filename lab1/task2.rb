def play_game
  # Комп'ютер загадує число від 1 до 100
  secret_number = rand(1..100)

  attempts = 0
  guess = nil

  puts "\n\n--- Гра 'Вгадай число' ---"
  puts "Я загадав число від 1 до 100. Спробуйте вгадати!"

  while guess != secret_number
    print "Ваше припущення: "
    guess_input = gets.chomp

    if guess_input.empty?
      puts "Будь ласка, введіть число."
      next
    end

    if guess_input.match?(/\D/)
      puts "Це не схоже на число. Спробуйте ще раз."
      next
    end

    guess = guess_input.to_i
    attempts += 1

    if guess < secret_number
      puts "Загадане число більше."
    elsif guess > secret_number
      puts "Загадане число менше."
    end
  end

  puts "🎉 Вгадано! Це було число #{secret_number}."
  puts "Ви впоралися за #{attempts} спроб."
end

# --- Демонстрація Завдання 2 ---
# Запускаємо гру
play_game