$(document).ready(function(){
  
  $(document).on('click', 'form#hit input', function() {
    $.ajax({
      type: 'POST',
      url: '/game/player/hit'
    }).done(function(msg) {
      $('#game').replaceWith(msg);
    });
    return false;
  });

  $(document).on('click', 'form#stay input', function() {
    $.ajax({
      type: 'POST',
      url: '/game/player/stay'
    }).done(function(msg) {
      $('#game').replaceWith(msg);
    });
    return false;
  });

  $(document).on('click', 'form#dealer_show_card input', function() {
    $.ajax({
      type: 'POST',
      url: '/game/dealer'
    }).done(function(msg) {
      $('#game').replaceWith(msg);
    });
    return false;
  });

});