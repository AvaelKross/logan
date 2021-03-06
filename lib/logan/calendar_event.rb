require 'logan/HashConstructed'

module Logan
  class CalendarEvent
    include HashConstructed

    attr_accessor :id
    attr_accessor :summary
    attr_accessor :description
    attr_accessor :created_at
    attr_accessor :updated_at
    attr_accessor :all_day
    attr_accessor :starts_at
    attr_accessor :ends_at
    attr_accessor :comments_count
    attr_accessor :url
    attr_accessor :app_url
    attr_accessor :trashed
    attr_accessor :private
    attr_accessor :recurring
    attr_accessor :recurrence
    attr_reader :creator
    attr_reader :comments
    attr_reader :subscribers

    # Sets the creator for this calendar event
    #
    # @param [Object] creator person hash from API or <Logan::Person> object
    def creator=(creator)
      @creator = creator.is_a?(Hash) ? Logan::Person.new(creator) : creator
    end

    # Sets subscribers for this calendar event
    #
    # @param [Object] subscribers person hash from API or <Logan::Person> object
    def subscribers=(subscribers_array)
      @subscribers = subscribers_array.map { |obj| obj = Logan::Person.new obj if obj.is_a?(Hash) }
    end

    # assigns the {#comments} from the passed array
    #
    # @param [Array<Object>] comment_array array of hash comments from API or <Logan::Comment> objects
    # @return [Array<Logan::Comment>] array of comments for this calendar event
    def comments=(comment_array)
      @comments = comment_array.map { |obj| obj = Logan::Comment.new obj if obj.is_a?(Hash) }
    end

    def create_comment(comment)
      post_params = {
        :body => comment.post_json,
        :headers => Logan::Client.headers.merge({'Content-Type' => 'application/json'})
      }

      response = Logan::Client.post "/projects/#{@project_id}/calendar_events/#{@id}/comments.json", post_params
      Logan::Comment.new response
    end
  end
end