$(document).ready(function()
{
	var selected = $(".panel-button.selected");
	$(".panel").hide();
	$("#" + selected.attr("data-panel")).show();
	
	$(".panel-button").click(function()
	{
		selected.removeClass("selected");
		$("#" + selected.attr("data-panel")).hide();
		
		selected = $(this);
		selected.addClass("selected");
		$("#" + selected.attr("data-panel")).show();
		event.preventDefault();
	});
});