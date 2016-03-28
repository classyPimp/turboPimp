class BlogsController < ApplicationController  
  
  def create

    @blog = Blog.new
    perms_for @blog
    auth! @perms

    @blog.attributes = @perms.permitted_attributes
    current_user.blogs << @blog

    if @blog.save && current_user.save
      render json: @blog.as_json(@perms.serialize_on_success)
    else
      render json: @blog.as_json(@perms.serialize_on_error)
    end

  end

  def index  
    per_page = params[:per_page] || 25
    search_query = params[:search_query]
    page = params[:page] || 1
    @model = Blog
    perms_for @model
    auth! @perms
    if !search_query.blank?
      @model = @model.search_by_title_body(search_query)
    else
      @model = @model.all
    end
    @model = @model.where(published: true)
    
    @model = @model.paginate(per_page: per_page, page: page)
    
    @model = @model.as_json(@perms.serialize_on_success) << extract_pagination_hash(@model)

    render json: @model
  end

  def index_for_group_list
    @blogs = Blog.published.last(5).reverse
    render json: @blogs.as_json(
      include: 
      {
        si_user1id: 
        {
          root: true,
          include: 
          [ 
            {
              si_profile1id_name:
              {
                root: true
              }
            },
            {
              avatar:
              {
                root: true,
                only: [:id],
                methods: 
                [
                  :url
                ]
              }
            }
          ]
        }
      }

    )
  end
   
  def edit 

    perms_for :Blog

    auth! @perms

    render json: @perms.model

  end

  def update
    @blog = Blog.find(params[:id])
    perms_for @blog
    auth! @perms

    if @blog.update(@perms.permitted_attributes)
      render json: @blog.as_json(@perms.serialize_on_success)
    else
      render json: @blog.as_json(@perm.serialize_on_error)
    end
  end

  def destroy
    @blog = Blog.find(params[:id])
    perms_for @blog
    auth! @perms

    if @blog.destroy
      render  json: @blog.as_json
    end
  end

  def show
    @blog = Blog.friendly.find(params[:id])
    perms_for @blog
    auth! @perms
    render json: @blog.as_json(@perms.serialize_on_success)
  end


  
end
