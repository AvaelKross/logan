require 'logan/HashConstructed'

module Logan
  class Comment
    include HashConstructed

    attr_accessor :id
    attr_accessor :content
    attr_accessor :created_at
    attr_accessor :updated_at
    attr_accessor :trashed
    attr_accessor :private
    attr_accessor :subscribers
    attr_reader :creator

    def post_json
      {
        :content => @content,
        :trashed => @trashed,
        :private => @private,
        :creator => @creator.nil? ? nil : @creator.to_hash
      }.to_json
    end

    # Sets the creator for this comment
    #
    # @param [Object] creator person hash from API or <Logan::Person> object
    def creator=(creator)
      @creator = creator.is_a?(Hash) ? Logan::Person.new(creator) : creator
    end
  end
end