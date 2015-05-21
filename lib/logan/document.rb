require 'logan/HashConstructed'

module Logan
  class Document
    include HashConstructed

    attr_accessor :id
    attr_accessor :title
    attr_accessor :content
    attr_accessor :created_at
    attr_accessor :updated_at
    attr_accessor :url
    attr_accessor :app_url
    attr_accessor :trashed
    attr_accessor :private
    attr_reader :bucket
    attr_reader :last_updater
    attr_reader :creator
    attr_reader :subscribers

    def refresh
      response = Logan::Client.get "/projects/#{@project_id}/documents/#{@id}.json"
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

      response = Logan::Client.post "/projects/#{@project_id}/documents/#{@id}/comments.json", post_params
      Logan::Comment.new response
    end
  end
end