class TransactionsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :correct_user,   only: :destroy
  before_action :valid_user, only: [:edit, :update]

  def new
  end

  def edit
  end

  def index
    #@user=current_user
    @transactions=current_user.transactions.order("created_at desc")
  end

  def create
    @transaction = current_user.transactions.build(transaction_params)
    if @transaction.save
     flash[:success] = "transaction created!"
     redirect_to transactions_path
    else
     @feed_items = []
     render 'static_pages/home'
   end
  end

  private
  # Confirms a valid user.
  def valid_user
    unless (@user && @user.activated? &&
            @user.authenticated?(:reset, params[:id]))
      redirect_to root_url
    end
  end

    def transaction_params
      params.require(:transaction).permit(:in,:out,:payment, :payment_type)
    end

    def correct_user
      @transaction = current_user.transaction.find_by(id: params[:id])
      debugger
      redirect_to(root_url) if @transaction.nil?
    end

end
