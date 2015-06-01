require 'logan/HashConstructed'
require 'open-uri'

module Logan
  class Attachment
    include HashConstructed

    attr_accessor :id
    attr_accessor :key
    attr_accessor :name
    attr_accessor :byte_size
    attr_accessor :content_type
    attr_accessor :created_at
    attr_accessor :updated_at
    attr_accessor :url
    attr_accessor :app_url
    attr_accessor :thumbnail_url
    attr_accessor :trashed
    attr_accessor :private
    attr_accessor :tags
    attr_accessor :attachable
    attr_accessor :token
    attr_reader :creator

    def create(project_id, data, content_type)
      post_params = {
        :body => data,
        :headers => Logan::Client.headers.merge({'Content-Type' => content_type})
      }

      response = Logan::Client.post "/projects/#{project_id}/attachments.json", post_params
      Logan::Attachment.new response
    end

    def create_by_url(project_id, url, content_type)
      data = nil
      open(url, 'rb') do |f| 
        data = f.read
      end
      create(project_id, data, content_type)
    end

    # Sets the creator for this comment
    #
    # @param [Object] creator person hash from API or <Logan::Person> object
    def creator=(creator)
      @creator = creator.is_a?(Hash) ? Logan::Person.new(creator) : creator
    end
  end
end