# frozen_string_literal: true

module Admin
  class MemberPostsController < BaseController
    def index
      @posts = policy_scope(MemberPost).order(created_at: :desc)
    end

    def new
      @post = MemberPost.new
      authorize @post
    end

    def create
      @post = MemberPost.new(post_params)
      authorize @post
      if @post.save
        redirect_to admin_member_posts_path, notice: "Contenido creado."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @post = MemberPost.find(params[:id])
      authorize @post
    end

    def update
      @post = MemberPost.find(params[:id])
      authorize @post
      if @post.update(post_params)
        redirect_to admin_member_posts_path, notice: "Contenido actualizado."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @post = MemberPost.find(params[:id])
      authorize @post
      @post.destroy
      redirect_to admin_member_posts_path, notice: "Contenido eliminado."
    end

    private

    def post_params
      params.require(:member_post).permit(:title, :slug, :excerpt, :body, :published_at, :cover_image)
    end
  end
end
