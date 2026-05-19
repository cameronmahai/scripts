$(function() {
  var trailer = $('#trailer').get(0);
  $(".video").click(function () {
    trailer.play();
    trailer.currentTime=0;
    trailer.volume=0.5;
  });
  $("#myModal").on('hidden.bs.modal', function(){
    trailer.pause();
  });
});

