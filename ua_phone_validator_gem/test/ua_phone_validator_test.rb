# frozen_string_literal: true

require "test_helper" # Або 'minitest/autorun'
require_relative "../lib/ua_phone_validator" # Переконайтесь, що шлях правильний

class UaPhoneValidatorTest < Minitest::Test
  
  def test_that_it_has_a_version_number
    refute_nil ::UaPhoneValidator::VERSION
  end

  def test_valid_numbers
    assert UaPhoneValidator.valid?("+380(97)123-45-67")
    assert UaPhoneValidator.valid?("0971234567")
    assert UaPhoneValidator.valid?("380971234567")
  end

  def test_invalid_numbers
    refute UaPhoneValidator.valid?("12345")
    refute UaPhoneValidator.valid?("09712345") # Короткий
    refute UaPhoneValidator.valid?("0111234567") # Неіснуючий код оператора
  end

  def test_e164_formatting
    assert_equal "+380971234567", UaPhoneValidator.format_e164("097-123-45-67")
    assert_equal "+380971234567", UaPhoneValidator.format_e164("+380(97)1234567")
  end

  def test_national_formatting
    assert_equal "0971234567", UaPhoneValidator.format_national("+380(97)123-45-67")
    assert_equal "0971234567", UaPhoneValidator.format_national("0971234567")
  end
end