require 'logan/HashConstructed'

module Logan
  class Message
    include HashConstructed

    attr_accessor :id
    attr_accessor :subject
    attr_accessor :content
    attr_accessor :private
    attr_accessor :trashed
    attr_reader :subscribers
    attr_reader :creator
    attr_reader :comments

    # Sets the creator for this message
    #
    # @param [Object] creator person hash from API or <Logan::Person> object
    def creator=(creator)
      @creator = creator.is_a?(Hash) ? Logan::Person.new(creator) : creator
    end

    # Sets subscribers for this message
    #
    # @param [Object] subscribers person hash from API or <Logan::Person> object
    def subscribers=(subscribers_array)
      @subscribers = subscribers_array.map { |obj| obj = Logan::Person.new obj if obj.is_a?(Hash) }
    end

    def refresh
      response = Logan::Client.get "/projects/#{@project_id}/messages/#{@id}.json"
      initialize(response.parsed_response)
    end

    # returns the array of comments - potentially synchronously downloaded from API
    #
    # @return [Array<Logan::Comment] Array of comments on this todo
    def comments
      refresh if (@comments.nil? || @comments.empty?) && @comments_count > 0
      @comments ||= Array.new
    end

    # assigns the {#comments} from the passed array
    #
    # @param [Array<Object>] comment_array array of hash comments from API or <Logan::Comment> objects
    # @return [Array<Logan::Comment>] array of comments for this todo
    def comments=(comment_array)
      @comments = comment_array.map { |obj| obj = Logan::Comment.new obj if obj.is_a?(Hash) }
    end

    def create_comment(comment)
      post_params = {
        :body => comment.post_json,
        :headers => Logan::Client.headers.merge({'Content-Type' => 'application/json'})
      }

      response = Logan::Client.post "/projects/#{@project_id}/messages/#{@id}/comments.json", post_params
      Logan::Comment.new response
    end
  end
end
