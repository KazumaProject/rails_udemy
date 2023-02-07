class BoardsController < ApplicationController
  before_action :set_target_board, only: %i[show edit update destroy]
  def index
    @boards = Board.page(params[:page])
  end

  def new
    @board = Board.new
  end

  def create
    board = Board.new(board_params)
    if board.save
      flash[:notice] = "「#{board.title}」の掲示板を作りました"
      redirect_to board
    else
      redirect_to new_board_path, flash: {
        board: board,
        error_messages: board.errors.full_messages
      }
    end
  end

  def show
    # @comment = @board.comments.new
    @comment = Comment.new(board_id: @board.id)
  end

  def edit
  end

  def update
    board = @board.update(board_params)
    if board == true
      redirect_to @board
    else
      redirect_to edit_board_path, flash: {
        board: @board,
        error_messages: @board.errors.full_messages
      }
    end
  end

  def destroy
    @board.delete
    redirect_to boards_path, flash: { notice: "「#{@board.title}の掲示板が削除されました」"}
  end

  private

  def board_params
    params.require(:board).permit(:name, :title, :body)
  end

  def set_target_board
    @board = Board.find(params[:id])
  end
end
