require 'logan/HashConstructed'

module Logan
  class Message
    include HashConstructed

    attr_accessor :id
    attr_accessor :subject
    attr_accessor :created_at
    attr_accessor :updated_at
    attr_accessor :content
    attr_accessor :private
    attr_accessor :trashed
    attr_accessor :attachments
    attr_reader :subscribers
    attr_reader :creator
    attr_reader :comments

    def post_json
      {
        :subject => @subject,
        :content => @content,
        :trashed => @trashed,
        :private => @private,
        :attachments => @attachments
      }.to_json
    end

    def create(project_id)
      post_params = {
        :body => self.post_json,
        :headers => Logan::Client.headers.merge({'Content-Type' => 'application/json'})
      }

      response = Logan::Client.post "/projects/#{project_id}/messages.json", post_params
      Logan::Message.new response
    end

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
