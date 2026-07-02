require 'net/http'
require 'json'
require 'uri'

class GamesController < ApplicationController
  def new
    @letters = ('A'..'Z').to_a.sample(10)
  end

  def score
    @word = params["word"].upcase
    @letters = params["letters"]
    word_hash = to_counter(@word.split(""))

    letter_hash = to_counter(@letters.split)


    if !counters_match(word_hash, letter_hash)
      @result = "Sorry but #{@word} can't be built out of #{@letters} "
      return
    end

    if !in_dictionary?(@word)
      @result = "Sorry but #{@word} does not seem to be a valid English word.."
      return
    end

    @result = "Congratulations! #{@word} is a valid English word!"

  end

  def to_counter(items)
    hash = {}
    items.each do |item|
      hash[item] = (hash[item] || 0) + 1
    end
    hash
  end

  def counters_match?(counter_a, counter_b)
    letters_match = true
    counter_a.each do |key, value|
      has_letter = counter_b[key] || 0
      letters_match = false if value > has_letter
    end
    letters_match
  end


  def in_dictionary?(word)
    uri = URI.parse("https://dictionary.lewagon.com/#{word}")
    response = Net::HTTP.get_response(uri)

    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      return data["found"]
    else
      puts "Error: #{response.code}"
    end

  end
end
