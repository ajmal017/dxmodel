class StockScoresController < ApplicationController
  # GET /stock_scores
  # GET /stock_scores.json
  def index
    @stock_scores = StockScore.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @stock_scores }
    end
  end

  # GET /stock_scores/1
  # GET /stock_scores/1.json
  def show
    @stock_score = StockScore.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @stock_score }
    end
  end

  # GET /stock_scores/new
  # GET /stock_scores/new.json
  def new
    @stock_score = StockScore.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @stock_score }
    end
  end

  # GET /stock_scores/1/edit
  def edit
    @stock_score = StockScore.find(params[:id])
  end

  # POST /stock_scores
  # POST /stock_scores.json
  def create
    @stock_score = StockScore.new(params[:stock_score])

    respond_to do |format|
      if @stock_score.save
        format.html { redirect_to @stock_score, notice: 'Stock score was successfully created.' }
        format.json { render json: @stock_score, status: :created, location: @stock_score }
      else
        format.html { render action: "new" }
        format.json { render json: @stock_score.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /stock_scores/1
  # PUT /stock_scores/1.json
  def update
    @stock_score = StockScore.find(params[:id])

    respond_to do |format|
      if @stock_score.update_attributes(params[:stock_score])
        format.html { redirect_to @stock_score, notice: 'Stock score was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @stock_score.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stock_scores/1
  # DELETE /stock_scores/1.json
  def destroy
    @stock_score = StockScore.find(params[:id])
    @stock_score.destroy

    respond_to do |format|
      format.html { redirect_to stock_scores_url }
      format.json { head :no_content }
    end
  end
end
