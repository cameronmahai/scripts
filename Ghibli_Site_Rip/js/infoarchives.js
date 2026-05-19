$(function() {
  var timestamp = parseInt((new Date)/1000);
  $('#infoarchives').load('https://www.ghibli.jp/data/infoarchives.dat?' + timestamp);
});
