require 'logan/HashConstructed'
require 'logan/comment'
require 'logan/person'
require 'logan/message'

module Logan
  class Topic
    include HashConstructed

    attr_accessor :id
    attr_accessor :title
    attr_accessor :excerpt
    attr_accessor :attachments
    attr_accessor :private
    attr_accessor :trashed
    attr_accessor :created_at
    attr_accessor :updated_at
    attr_accessor :topicable
    attr_accessor :last_updater
    attr_accessor :topicable
    attr_accessor :bucket

    def topicable_object
      @topicable_object ||= set_topicable
    end

    private

      def set_topicable
        case @topicable['type']
        when "Message" 
          Logan::Message.new({id: @topicable['id']})
        when "Document"
          Logan::Document.new({id: @topicable['id']})
        when "Todo"
          Logan::Todo.new({id: @topicable['id']})
        when "Todolist"
          Logan::TodoList.new({id: @topicable['id']})
        else
          nil
        end
      end

  end
end
