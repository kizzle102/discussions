require 'pry-byebug'

class DiscussionsController < ApplicationController

  def index
    @discussions = Discussion.all
  end

  def show
    discussions = Discussion.all
    discussion_ids = discussions.map {|d| d.id}
    if discussion_ids.include?(params[:id].to_i)
      @discussion = Discussion.find(params[:id])
    else
      redirect_to discussions_path
    end
  end

  def show_leader
    discussions = Discussion.all
    discussion_ids = discussions.map {|d| d.id}

    if !discussion_ids.include?(params[:id].to_i)
      redirect_to discussions_path
    end

    @discussion = Discussion.find(params[:id])

    if params[:new] == 'true'
      render :show_leader
      return
    end

    if params[:leader_code] != @discussion.leader_code
      @message = 'The Leader Code entered was not correct.'
      redirect_to discussion_path(@discussion)
    end
  end

  def create
    @discussion = Discussion.new(discussion_params)
    # codes = generate_codes
    # @discussion.leader_code, @discussion.participant_code = codes.first, codes.last
    if @discussion.save
      WebsocketRails[:new_discussion].trigger(:update_discussions_index, @discussion)
      redirect_to :action => "show_leader", :id => @discussion.id, :new => true
    else
      @message = 'There was an error creating your discussion'
      redirect_to root_path
    end
  end

  # def generate_codes(size = 6)
  #   charset = [('a'..'z').to_a, ('A'..'Z').to_a, ('0'..'9').to_a].flatten
  #   begin
  #     code1 = (0...size).map{ charset[rand(charset.size)] }.join
  #     code2 = (0...size).map{ charset[rand(charset.size)] }.join 
  #   end until code1 != code2
  #   return [code1, code2]
  # end

  private
    def discussion_params
      params.require(:discussion).permit(:title, :leader_email, :leader_code, :participant_code)
    end
end
