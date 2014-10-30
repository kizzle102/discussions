require 'pry-byebug'

class QuestionsController < ApplicationController

  def create
    @question = Question.new(question_params)
    @question.question_status = 'unanswered'
    @question.response = 'N/A'
    if @question.save
      WebsocketRails[:new_question].trigger(:add_new_question, @question)
      @message = 'Question added successfully.'
    else
      @message = 'There was an error creating your discussion.'
    end
    respond_to do |format|
      format.js { render :layout => false }
    end
  end

  private
    def question_params
      params.require(:question).permit(:content, :discussion_id)
    end
end
