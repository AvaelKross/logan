require 'logan/HashConstructed'

module Logan
  class Upload
    include HashConstructed

    attr_accessor :id
    attr_accessor :content
    attr_accessor :created_at
    attr_accessor :updated_at
    attr_accessor :trashed
    attr_accessor :attachments
    attr_reader :comments
    attr_reader :subscribers

    # Sets subscribers for this upload
    #
    # @param [Object] subscribers person hash from API or <Logan::Person> object
    def subscribers=(subscribers_array)
      @subscribers = subscribers_array.map { |obj| obj = Logan::Person.new obj if obj.is_a?(Hash) }
    end

    # assigns the {#comments} from the passed array
    #
    # @param [Array<Object>] comment_array array of hash comments from API or <Logan::Comment> objects
    # @return [Array<Logan::Comment>] array of comments for this upload
    def comments=(comment_array)
      @comments = comment_array.map { |obj| obj = Logan::Comment.new obj if obj.is_a?(Hash) }
    end

    def create_comment(comment)
      post_params = {
        :body => comment.post_json,
        :headers => Logan::Client.headers.merge({'Content-Type' => 'application/json'})
      }

      response = Logan::Client.post "/projects/#{@project_id}/uploads/#{@id}/comments.json", post_params
      Logan::Comment.new response
    end
  end
end