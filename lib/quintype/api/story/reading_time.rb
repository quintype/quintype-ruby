module ReadingTime
  extend ActiveSupport::Concern
  WORDS_PER_MINUTE=275
  SLOW_IMAGE_LIMIT=10
  INITIAL_IMAGE_READ_TIME=12
  FINAL_IMAGE_READ_TIME=3
  ESTIMATED_TWEET_WORDS=30

  def time_in_minutes
    (time_in_seconds.to_f/60).ceil
  end

  def time_in_seconds
    words_and_image_count_for_cards = cards.flat_map do |card|
      if card['story_elements'].present?
        card['story_elements'].map do |element|
          {
            'words' => word_count_for_story_element(element),
            'images' => image_count(element)
          }
        end
      end
    end.compact
    total_words_and_image_count = total_image_and_words_count(words_and_image_count_for_cards)
    total_readtime(total_words_and_image_count)
  end

  private
  def total_readtime(total_words_and_image_count)
    (total_words_and_image_count["words"].to_i/(WORDS_PER_MINUTE/60)) + image_read_time(total_words_and_image_count)
  end

  def image_read_time(total_words_and_image_count)
    read_time = 0
    total_words_and_image_count['images'].times do |i|
      read_time += (i >= SLOW_IMAGE_LIMIT ? FINAL_IMAGE_READ_TIME : INITIAL_IMAGE_READ_TIME - i)
    end
    read_time
  end

  def total_image_and_words_count(words_and_image_counts)
    {
      'words' => total(words_and_image_counts, 'words'),
      'images' => total(words_and_image_counts, 'images')
    }
  end

  def total(words_and_image_counts, element)
    total = 0
    words_and_image_counts.each do |word_and_image_count|
      total += word_and_image_count[element]
    end
    total
  end

  def image_count(story_element)
    if story_element['type'] == "image" || ['location','instagram'].include?(story_element['subtype'])
      1
    else
      0
    end
  end

  def word_count_for_story_element(story_element)
    case story_element['type']
    when "text"
      text_word_count(story_element['text'])
    when "jsembed"
      jsembed_word_count(story_element['jsembed'])
    else
      0
    end
  end

  def text_word_count(text)
    if text.present?
      text.split.size
    else
      0
    end
  end

  def jsembed_word_count(story_element)
    if story_element.present? && story_element['subtype'] == "tweet"
      ESTIMATED_TWEET_WORDS
    else
      0
    end
  end
end
