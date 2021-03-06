class ##{plural.camelize}Controller < ApplicationController
  before_action :set_##{table.downcase}, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_filter :ensure_signup_complete, only: [:new, :create, :update, :destroy] 

  def index
    authorize ##{table.camelize}
    @##{plural.downcase} = ##{table.capitalize}.search(params[:search])
  end

  def show
    authorize @##{table.downcase}
  end

  def new
    authorize ##{table.camelize}
    @##{table.downcase} = ##{table.capitalize}.new
    ##{nested_build_children}
  end

  def edit
    authorize @##{table.downcase}
    ##{nested_build_children}
  end

  def create
    @##{table.downcase} = ##{table.capitalize}.new(##{table.downcase}_params)
    authorize @##{table.downcase}

    if @##{table.downcase}.save
      if params[:parent_controller].present?
        redirect_to controller: params[:parent_controller], action: params[:parent_action], id: params[:parent_id].to_i, notice: '##{table.capitalize} was successfully created.'
      else
        redirect_to ##{plural.downcase}_path, notice: '##{table.capitalize} was successfully created.'
      end
    else
      render :new
    end
  end

  def update
    authorize @##{table.downcase}
    if @##{table.downcase}.update(##{table.downcase}_params)
      if params[:parent_controller].present?
        redirect_to controller: params[:parent_controller], action: params[:parent_action], id: params[:parent_id].to_i, notice: '##{table.capitalize} was successfully updated.'
      else
        redirect_to ##{plural.downcase}_path, notice: '##{table.capitalize} was successfully updated.'
      end
    else
      render :edit
    end
  end

  def destroy
    authorize @##{table.downcase}
    @##{table.downcase}.destroy
    redirect_to ##{plural.downcase}_url, notice: '##{table.capitalize} was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_##{table.downcase}
      @##{table.downcase} = ##{table.capitalize}.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ##{table.downcase}_params
      params.require(:##{table.downcase}).permit(##{permit})
    end
end
