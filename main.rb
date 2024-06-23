# Brody Jeanes
# 10568619

require "json"
require "net/http"

# This function downloads a text file of a list of every english word in the dictionary from a github
def download_dictionary
  puts "Dictionary File Cannot Be Found. Downloading Dictionary File..."
  url = URI.parse("https://raw.githubusercontent.com/dwyl/english-words/master/words_alpha.txt") # Uses the "net/http" gem to download the english dictionary from a github repository
  File.open("words_alpha.txt", "wb") do |dictionary|
    dictionary.write(Net::HTTP.get_response(url).body)
  end
  puts "Dictionary Has Been Downloaded Successfully."
end

# This function converts the dictionary file (words_alpha.txt) into a JSON file (words.json)
def convert_json
  puts "Converting Dictionary File to JSON..."
  dictionaryJson = File.readlines("words_alpha.txt").map(&:strip)
  File.open("words.json", "w") do |dictionary|
    dictionary.write(JSON.pretty_generate(dictionaryJson)) # Pretty prints the json file so its more readable form a developers perspective
  end
  puts "Conversion To JSON Complete."
end

# This function takes the users input and generates a random password with a random special character and number. 
def generate_password(word_length)
  dict = JSON.parse(File.read("words.json"))
  min_word_length = word_length - 2 # Subtracts 2 for the special character and number
  valid_words = dict.select { |indiv_word| indiv_word.length == min_word_length }
  
  if valid_words.empty? # If no words in the dictionary have the same length as the users input, then the user will be reprompted to enter a new integer
    puts "No Words In The Dictionary With Length #{word_length}."
    prompt_password
  else
    random_word = valid_words.sample

    # Randomly select a position to insert a special character
    special_char_position = rand(0..random_word.length)
    random_special_char = ("!@#$%^&*").split("").sample
    random_word.insert(special_char_position, random_special_char)
    
    # Randomly select a position to insert a digit
    digit_position = rand(0..random_word.length)
    random_digit = rand(0..9).to_s
    random_word.insert(digit_position, random_digit)

    puts "Randomly Generated Password Is: #{random_word}"
    save_menu(random_word)
  end
end

# This function provides the user with options to select once the program has been run. 
# 1. allows the user to generate a random password, 2. allows the user to view any saved passwords and 0. closes the program
def main_menu
  puts "\n----------------------------------"
  print "    Random Password Generator\n           Main Menu\n\n1. Generate a random password\n2. View saved passwords\n0. Quit\nEnter: "
  choice = gets.chomp.to_i # Removes any whitespace or other characters that aren't an integer
  case choice
  when 1
    prompt_password
  when 2
    view_saved_passwords
  when 0
    puts "Program Now Exiting"
    exit
  else
    puts "Invalid Choice. Please Try Again."
    main_menu
  end
end

# This function provides the user with options after they have generated a random password.
# 1. allows the user to save the password that they have just generated to a new JSON file. 2. allows the user to generate a new random password and 0. returns the user back to the main menu
def save_menu(password)
  puts "\n----------------------------------\n              Options\n\n"
  puts "1. Save Password"
  puts "2. Generate New Password"
  puts "0. Return"
  print "Enter: "
  choice = gets.chomp.to_i # Removes any whitespace or other characters that aren't an integer
  case choice
  when 1
    save_password(password)
  when 2
    prompt_password
  when 0
    main_menu
  else
    puts "Invalid Choice. Please Try Again."
    save_option(password)
  end
end

# This function saves the password that the user wants to save to a new JSON file called passwords.json
def save_password(password)

  # This section checks to see if the password.json file exists. If it does then it will skip creating a new file
  if !File.exist?("passwords.json")
    passwords = []
  else
    passwords = JSON.parse(File.read("passwords.json"))
  end
  
  passwords << password
  File.open("passwords.json", "w") do |file|
    file.write(JSON.pretty_generate(passwords))
  end

  puts "\nPassword saved successfully."
  main_menu
end

# This function allows the user to enter their desired password length
def prompt_password
  print "\n----------------------------------\n\nEnter The Length Of Your Password: "
  word_length = gets.chomp.to_i # Removes any whitespace or other characters that aren't an integer

  while word_length <= 0 
    print "Invalid Input. Please Enter A Integer: "
    word_length = gets.chomp.to_i
  end

  selected_word = generate_password(word_length)
end

# This function allows the user to view any saved passwords that exist in the passwords.json file.
def view_saved_passwords
  # This section checks to see if the passwords.json file exists. If it does then it will open it in read only.
  if File.exist?("passwords.json")
    passwords = JSON.parse(File.read("passwords.json"))
    if passwords.empty?
      puts "\nNo Passwords Saved Yet."
    else
      puts "\n----------------------------------\n          Saved Passwords\n\n"
      passwords.each { |password| puts password }
    end
  else
    puts "\nNo Passwords Saved Yet."
  end
  main_menu
end

# This section of code will be the first initial pieces of code that will run when the progam is first launched
# This section will first check if the "words_alpha.txt" dictionary file exists. If it doesn't then it will download the dictionary file
# Then the code will check if the "words.json" file exists. If it doesn't then it will convert the dictionary file to a JSON file

begin

  download_dictionary unless File.exist?("words_alpha.txt")
    if File.exist?("words_alpha.txt")
      puts "\nDictionary File Already Exists. Skipping Download."
    end

  convert_json unless File.exist?("words.json")
    if File.exist?("words.json")
      puts "JSON File Of The Dictionary Already Exists. Skipping Conversion."
    end

  main_menu

rescue StandardError => e
  puts "Fatal Error: #{e.message}"
end