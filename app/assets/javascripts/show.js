var emptyLists = function() {
	$('p.no-items').remove();
	var surveyItems = $('ul.survey-list li');
	var questions = $('ul.answered-questions-list li');
	if (surveyItems.length === 0) {
		$('ul.survey-list').append('<p class="no-surveys no-items"><em>There are currently no open surveys.</em></p>');
	};
	if (questions.length === 0) {
		$('ul.answered-questions-list').append('<p class="no-questions no-items"><em>The leader has not answered any questions yet.</em></p>');
	};
};

$('.discussions.show').ready(function(){
	emptyLists();

	$('ul.nav-tabs').on('click', 'li', function() {
		$('ul.nav-tabs').children().removeClass("active");
		var tab = $(this).attr('class');
		$('div#participant-content-container').children().hide();
		$('p.message-container').empty();
		switch (tab) {
			case 'show-question-form':
				$('div.question-form-container').show();
				break;
			case 'show-questions':
				$('div.answered-questions-container').show();
				break;
			default:
				$('div.surveys-container').show();
				break;
		}
		$(this).addClass("active");
	});

	$(document).ajaxSuccess(function() {
		emptyLists();
	});

	var channel = dispatcher.subscribe('surveys');
	channel.bind('open_survey', function(data) {
	  var survey_question = data['survey_question'];
	  var survey_id = data['id'];
	  if ($('div#survey' + survey_id).length == 0) {
		  var surveyResponseHtml = '<li><strong>' + survey_question + '</strong></li><div id="survey' + survey_id + '"><form accept-charset="UTF-8" action="/surveys/' + survey_id + '/survey_responses" data-remote="true" method="post" role="form"><div style="display:none"><input name="utf8" type="hidden" value="✓"></div><div class="form-group"><textarea type="text" class="form-control" rows="3" name="survey_response[content]" id="survey' + survey_id + '-response"></textarea></div><input type="hidden" name="survey_response[survey_id]" value="' + survey_id + '""><input type="submit" value="Submit Response" class="btn btn-xs btn-default"></form></div>';
		  $('ul.survey-list').append(surveyResponseHtml);
	  };
	  emptyLists();
	});
	channel.bind('end_survey', function(data) {
	  var survey_id = data['id'];
	  $('div#survey' + survey_id).prev('li').remove();
	  $('div#survey' + survey_id).remove();
	  emptyLists();
	});
	channel.bind('timer', function(data) {
		var totalSeconds = parseInt(data['seconds']);
		$('div#' + data['id'] + ' p.timer').remove();
		$('div#' + data['id']).prepend('<p class="timer"></p>');
		for (var i = totalSeconds; i > 0; i--) {
			setTimeout(function(x) {
				return function() { 
					if (x < 10) {
						$('div#' + data['id'] + ' p.timer').text('0:0' + String(x) + ' until survey closes');
					} else if (x < 60) {
						$('div#' + data['id'] + ' p.timer').text('0:' + String(x) + ' until survey closes');
					} else {
						var minutes = Math.floor(x/60);
						var seconds = x % 60;
						if (seconds < 10) {
							$('div#' + data['id'] + ' p.timer').text(String(minutes) + ':0' + String(seconds) + ' until survey closes');
						} else {
						 $('div#' + data['id'] + ' p.timer').text(String(minutes) + ':' + String(seconds) + ' until survey closes');
						};
					};
				}; 
			}(i), 1000*(totalSeconds-i));
		};
		emptyLists();
	});

	var channel2 = dispatcher.subscribe('questions');
	channel2.bind('respond_to_question', function(data) {
		if ($('li#response-question-' + data['id']).length == 0) {
			$('.answered-questions-list').append('<li id="response-question-' + data['id'] + '">' + data['content'] + '</li><p><strong>Answer: </strong><em>' + data['response'] + '</em></p>');
			emptyLists();
		};
	});
})