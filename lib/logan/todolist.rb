require 'logan/HashConstructed'
require 'logan/todo'

module Logan
  class TodoList
    include HashConstructed

    attr_accessor :id
    attr_accessor :project_id
    attr_accessor :name
    attr_accessor :description
    attr_accessor :completed
    attr_accessor :remaining_count
    attr_accessor :completed_count
    attr_accessor :url
    attr_writer :remaining_todos
    attr_writer :completed_todos
    attr_reader :creator
    attr_reader :comments

    # intializes a todo list by calling the HashConstructed initialize method and
    # setting both @remaining_todos and @completed_todos to empty arrays
    def initialize(h)
      @remaining_todos = []
      @completed_todos = []
      super
    end

    def post_json
        { :name => @name, :description => @description }.to_json
    end

    # refreshes the data for this todo list from the API
    def refresh
      response = Logan::Client.get "/projects/#{@project_id}/todolists/#{@id}.json"
      initialize(response.parsed_response)
    end

    # returns the array of remaining todos - potentially synchronously downloaded from API
    #
    # @return [Array<Logan::Todo>] Array of remaining todos for this todo list
    def remaining_todos
      if @remaining_todos.empty? && @remaining_count > 0
        refresh
      end

      return @remaining_todos
    end

    # returns the array of completed todos - potentially synchronously downloaded from API
    #
    # @return [Array<Logan::Todo>] Array of completed todos for this todo list
    def completed_todos
      if @completed_todos.empty? && @completed_count > 0
        refresh
      end

      return @completed_todos
    end

    # returns an array of all todos, completed and remaining - potentially synchronously downloaded from API
    #
    # @return [Array<Logan::Todo>] Array of completed todos for this todo list
    def todos
      remaining_todos + completed_todos
    end

    # assigns the {#remaining_todos} and {#completed_todos} from the associated keys
    # in the passed hash
    #
    # @param [Hash] todo_hash hash possibly containing todos under 'remaining' and 'completed' keys
    # @return [Array<Logan::Todo>] array of remaining and completed todos for this list
    def todos=(todo_hash)
      @remaining_todos = todo_hash['remaining'].map { |h| Logan::Todo.new h.merge({ :project_id => @project_id }) }
      @completed_todos = todo_hash['completed'].map { |h| Logan::Todo.new h.merge({ :project_id => @project_id }) }
      return @remaining_todos + @completed_todos
    end

    # searches the remaining and completed todos for the first todo with the substring in its content
    #
    # @param [String] substring substring to look for
    # @return [Logan::Todo] the matched todo, or nil if there wasn't one
    def todo_with_substring(substring)
      issue_todo = @remaining_todos.detect{ |t| !t.content.index(substring).nil? }
      issue_todo ||= @completed_todos.detect { |t| !t.content.index(substring).nil? }
    end

    # create a todo in this todo list via the Basecamp API
    #
    # @param [Logan::Todo] todo the todo instance to create in this todo lost
    # @return [Logan::Todo] the created todo returned from the Basecamp API
    def create_todo(todo)
      post_params = {
        :body => todo.post_json,
        :headers => Logan::Client.headers.merge({'Content-Type' => 'application/json'})
      }

      response = Logan::Client.post "/projects/#{@project_id}/todolists/#{@id}/todos.json", post_params
      Logan::Todo.new response
    end

    # update a todo in this todo list via the Basecamp API
    #
    # @param [Logan::Todo] todo the todo instance to update in this todo list
    # @return [Logan::Todo] the updated todo instance returned from the Basecamp API
    def update_todo(todo)
      put_params = {
        :body => todo.put_json,
        :headers => Logan::Client.headers.merge({'Content-Type' => 'application/json'})
      }

      response = Logan::Client.put "/projects/#{@project_id}/todos/#{todo.id}.json", put_params
      Logan::Todo.new response
    end

    # delete a todo in this todo list via delete call to Basecamp API
    #
    # @param [Logan::Todo] todo the todo instance to be delete from this todo list
    # @return [HTTParty::response] response from Basecamp for delete request
    def delete_todo(todo)
      response = Logan::Client.delete "/projects/#{@project_id}/todos/#{todo.id}.json"
    end

    # Sets the creator for this todolist
    #
    # @param [Object] creator person hash from API or <Logan::Person> object
    def creator=(creator)
      @creator = creator.is_a?(Hash) ? Logan::Person.new(creator) : creator
    end

    # assigns the {#comments} from the passed array
    #
    # @param [Array<Object>] comment_array array of hash comments from API or <Logan::Comment> objects
    # @return [Array<Logan::Comment>] array of comments for this todo
    def comments=(comment_array)
      @comments = comment_array.map { |obj| obj = Logan::Comment.new obj if obj.is_a?(Hash) }
    end

    # create a create in this todo list via the Basecamp API
    #
    # @param [Logan::Comment] todo the comment instance to create in this todo lost
    # @return [Logan::Comment] the created comment returned from the Basecamp API
    def create_comment(comment)
      post_params = {
        :body => comment.post_json,
        :headers => Logan::Client.headers.merge({'Content-Type' => 'application/json'})
      }

      response = Logan::Client.post "/projects/#{@project_id}/todolists/#{@id}/comments.json", post_params
      Logan::Comment.new response
    end
  end
end