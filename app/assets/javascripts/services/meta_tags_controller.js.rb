module Services
  class MetaTagsContoller

    def initialize( title = 'turboPimp', description = '', keywords = '' )

      set_title(title)

      set_meta_keywords(keywords)

      set_meta_description(description)

    end

    def set_title(val)
      `$('title').html(#{val})`
    end

    def set_meta_keywords(val)
      `$('#keywords_meta').attr('content', #{val})`
    end

    def set_meta_description(val)
      `$('#description_meta').attr('content', #{val})`
    end

  end
end