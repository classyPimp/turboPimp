module Perms      
  class BlogRules < Perms::Base

    def create
      if @current_user && @current_user.has_role?(:blogger)
        @permitted_attributes = params.require(:blog).permit(:title, :body, :m_title, :m_keywords, :m_description, :published)
        @serialize_on_success = {}
        @serialize_on_error = {methods: [:errors]}
      end
    end

    def index

      
        per_page = params[:per_page] || 25

        search_query = params[:search_query] || false

        page = params[:page]

        @model = Blog.includes(:author).where(published: true)

        if !search_query.blank?
          @model = @model.search_by_title_body(search_query)
        else
          @model = @model.all
        end

        @model = @model.paginate(per_page: per_page, page: page)
        
        @model = @model.as_json(
            include: [author: {root: true, only: [:name]}]
          ) << @controller.extract_pagination_hash(@model)
        
      
        
    end

    def blogger_index

      if @current_user && @current_user.has_role?(:blogger)

        per_page = params[:per_page] || 25

        search_query = params[:search_query] || false

        page = params[:page]

        @model = @model.where(user_id: @current_user.id)

        if !search_query.blank?
          @model = @model.search_by_title_body(search_query)
        #else
        #  @model = @model.all
        end

        @model = @model.paginate(per_page: per_page, page: page)

        @model = @model.as_json(
             include: [author: {root: true, only: [:name]}]
          ) << @controller.extract_pagination_hash(@model)
        
      end

    end

    def edit
      
      if @current_user
        @model = Blog.find(params[:id])

        if @model.user_id == @current_user.id && @current_user.has_any_role?(:admin, :root, :blogger)
          @model = @model.as_json
        end
      end

    end

    def show
      if @model.published
        return true
      else
        return true if @current_user.id == @model.user_id
      end
    end

    def update
      if @current_user
        @model = Blog.find(params[:id])

        if @model.user_id == @current_user.id && @current_user.has_any_role?(:admin, :root, :blogger)
          @permitted_attributes = params.require(:blog).permit(:title, :body, :m_title, :m_keywords, :m_description, :published)
          @serialize_on_success = {}
          @serialize_on_error = {methods: [:errors]}
        end
      end
    end

    def destroy
      if @current_user && @current_user.has_role?(:blogger) && @current_user.id == @blog.id
        true
      end
    end

    def blogger_last_ten
      
      if @current_user && @current_user.has_any_role?(:blogger)
        
        @model = Blog.where(user_id: @current_user.id).last(10)
        @model = @model.as_json

      end

    end

    def blogger_toggle_published
      if @current_user.id == @model.user_id
        true
      end
    end

  end
end