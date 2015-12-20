module Perms
  class PageRules < Perms::Base


    def create
      if @current_user && @current_user.has_role?(:admin)
        @permitted_attributes = params.require(:page).permit(:title, :body, :m_title, :m_keywords, :m_description)
        @serialize_on_success = {}
        @serialize_on_error = {methods: [:errors]}
      end
    end

    def index
      per_page = params[:per_page] || 25
      search_query = params[:search_query]
      page = params[:page]
      @model = Page
      if !search_query.blank?
        @model = @model.search_by_title_body(search_query)
      else
        @model = @model.all
      end
      @model = @model.paginate(per_page: per_page, page: page)
      @model = @model.as_json() << @controller.extract_pagination_hash(@model)
    end
      
    def admin_index
      if @current_user && @current_user.has_role?(:admin)
        per_page = params[:per_page] || 25
        search_query = params[:search_query]
        page = params[:page]
        @model = Page
        if !search_query.blank?
          @model = @model.search_by_title_body(search_query)
        else
          @model = @model.all
        end
        @model = @model.paginate(per_page: per_page, page: page)
        @model = @model.as_json() << @controller.extract_pagination_hash(@model)
      end
    end

    def edit
      if @current_user
        if @current_user.has_any_role?(:admin, :root)
          true
        end
      end
    end

    def update
      if @current_user
        if @current_user.has_any_role?(:admin, :root)
          @permitted_attributes = params.require(:page).permit(:title, :body, :m_title, :m_keywords, :m_description)
          @serialize_on_success = {}
          @serialize_on_error = {methods: [:errors]}
        end
      end
    end

    def destroy
      if @current_user && @current_user.has_role?(:admin)
        true
      end
    end


  end
end