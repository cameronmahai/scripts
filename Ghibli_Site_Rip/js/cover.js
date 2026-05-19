$(function() {
  var bg_id = 'ghibli';
  $(document).ready(function(){
    var loadimg = new Image();
    loadimg.src = $('#coverbg-' + bg_id).attr('src') +"?"+ new Date().getTime();
    setSize(bg_id);
    newsTicker();
    $(window).resize(function(){
      setSize(bg_id);
    });
    loadimg.onload = function() {
      setSize(bg_id);
      hideBg();
      loadBg(bg_id);
    };
  });


});
function setSize(bg_id) {
  var imgW = 1200;
  var imgH = 800;
  var winW = $(window).width();
  var winH = $(window).height();
  var navH = $('#top').height();
  var bottomH = $('#headerbottom').height();
  var winH = winH - navH;
  var scaleW = winW / imgW;
  var scaleH = winH / (imgH + navH);
  var scale = Math.min(scaleW, scaleH);

  var setH = (imgH * winW / imgW) - navH + bottomH;
  var setW = winW;
  var moveH = setH + bottomH;
  var moveY = 0;
  var moveX = 0;


//580
//750
  if (winW > 768) {
    if (winH - bottomH < setH) {
      setH = imgH * scale;
      setW = imgW * scale;

      var moveH = winH;
      var moveY = Math.floor((winH - bottomH - setH) / 2);
      var moveX = Math.floor((winW - setW) / 2);

    }
    $('#headerbottom').css({
      'position': 'absolute',
      'bottom': 0,
      'z-index': 100
    });
    $('.slide').css({
      'height': moveH
    });
    $('.cover').css({
      'position': 'absolute',
      'left': 0,
      'top': 0,
      'width': setW,
      'height': setH
    });
  } else {
    $('#headerbottom').css({
      'position': 'static',
      'bottom': 'auto',
      'z-index': 'auto'
    });

    $('.slide').css({
      'height': 'auto'
    });
    $('.cover').css({
      'position': 'static',
      'width': setW,
      'height': setH
    });
  }
  $('#coverbg-' + bg_id).css({
    'top' : moveY,
    'left' : moveX,
    'width': setW,
    'height': setH
  });
}
function hideBg() {
  $('.slide').css({'opacity': 0});
  $('.slide').hide();
}
function loadBg(bg_id) {
  $('#coverbg-' + bg_id).show();
  $('#slide-' + bg_id).show();
  $('#slide-' + bg_id).animate({opacity: 1}, {duration: 'slow' , easing: 'swing'});
}


function newsTicker() {
  var $setElm = $('#ticker');
  var effectSpeed = 1000;
  var switchDelay = 7000;
  var easing = 'swing';

  $setElm.each(function(){

    var $targetObj = $(this);
    var $targetUl = $targetObj.children('ul');
    var $targetLi = $targetObj.find('li');
    var $setList = $targetObj.find('li:first');

    var ulWidth = $targetUl.width();
    var listHeight = $targetLi.height();
    $targetObj.css({height:(listHeight)});
    $targetLi.css({top:'0',left:'0',position:'absolute'});

    $setList.css({display:'block',opacity:'0',zIndex:'98'}).stop().animate({opacity:'1'},effectSpeed,easing).addClass('showlist');

    setInterval(function(){
      var $activeShow = $targetObj.find('.showlist');
      $activeShow.animate({opacity:'0'},effectSpeed,easing,function(){
        $(this).next().css({display:'block',opacity:'0',zIndex:'99'}).animate({opacity:'1'},effectSpeed,easing).addClass('showlist').end().appendTo($targetUl).css({display:'none',zIndex:'98'}).removeClass('showlist');
      });
    },switchDelay);

  });
}


