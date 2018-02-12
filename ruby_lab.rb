
# !/usr/bin/ruby
###############################################################
#
# CSCI 305 - Ruby Programming Lab
#
# Spencer Cornish
# spencerjcornish@gmail.com
#
###############################################################

$bigrams = {} # The Bigram data structure
$name = 'Spencer Cornish'

$stop_words = %w[
  a an and by for from in of on or out the to with
]
# matchers for various characters we want to remove, as well as the text after it
$supr_matchers = [
  /(feat.*)/i,
  /(\(.*)/i,
  /(\[.*)/i,
  /(\{.*)/i,
  /(\\.*)/i,
  /(\/.*)/i,
  /(_.*)/i,
  /(-.*)/i,
  /(:.*)/i,
  /(\".*)/i,
  /(\`.*)/i,
  /(\+.*)/i,
  /(\=.*)/i,
  /(\*.*)/i
]
# Assembled regex of the above matchers
$assembled_reg = Regexp.union($supr_matchers)

# function to process each line of a file and extract the song titles
def process_file(file_name)
  puts 'Processing File.... '
  IO.foreach(file_name) do |line|
    title = cleanup_title(line)
    add_to_bigrams(title)
  end
  puts "Finished. Bigram model built.\n"
end

# Method for cleaning up song titles. Returns a cleaned title
def cleanup_title(line)
  # Strip off everything but the song title
  line = line.gsub(/.*<SEP>/i, '')

  # Strip off featured artists, etc.
  line = line.gsub($assembled_reg, '')

  # Strip out punctuation characters
  line = line.gsub(/\?|¿|!|¡|\.|;|&|@|%|#|\|/, '')

  # remove non english characters
  line = line.gsub(/^\x00-\x7F|[0-9]/, '')

  line.downcase
end

# Adds a title to the bigram hash
def add_to_bigrams(title)
  words = title.split(' ')
  # For each word:
  iter = 0
  while iter < words.length
    curWord = words[iter]
    nextWord = words[iter + 1]
    #  We have a word pair to store
    if !curWord.nil? && !nextWord.nil?
      # The root word already exists in our hash
      if !$bigrams[curWord].nil?
        #  Add the word, or increment the existing value
        !$bigrams[curWord][nextWord].nil? ? $bigrams[curWord][nextWord] += 1 : $bigrams[curWord][nextWord] = 1
      else
        # Add our current word and this pair for the first time
        $bigrams[curWord] = { nextWord => 1 }
      end
    end

    iter += 1
  end
end

# Returns the most commonly repeated word after the input word.
# Returns nil if none exist.
def mcw(word)
  # Define a place to store the top match
  highest_word = ''
  highest_value = 0
  # Check and see if we have any matches at all
  match_hash = $bigrams[word]
  return nil if match_hash.nil?
  # search for the highest pair
  match_hash.each do |key, val|
    if val > highest_value
      highest_word = key
      highest_value = val
    end
  end
  highest_word
end

# Returns a title made up of common matches
def create_title(word)
  title = word
  nextWord = word
  for _ in 0..18
    # get the next most common word
    nextWord = mcw(nextWord)
    # If there isn't a match, the title is done
    break if nextWord.nil?
    # Append our new word to the title
    title = title + ' ' + nextWord
  end
  title
end

# Executes the program
def main_loop
  puts "CSCI 305 Ruby Lab submitted by #{$name}"

  if ARGV.empty?
    puts 'You must specify the file name as the argument.'
    exit 4
  end

  # process the file
  process_file(ARGV[0])

  # Get user input
  loop do
    print 'Enter a word [Enter \'q\' to quit]: '
    option = STDIN.gets.chomp
    exit 0 if option == 'q'
    puts create_title(option)
  end
end

main_loop if $PROGRAM_NAME == __FILE__
