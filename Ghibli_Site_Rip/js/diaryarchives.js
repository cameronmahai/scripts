$(function() {
  var timestamp = parseInt((new Date)/1000);
  $('#diaryarchives').load('https://www.ghibli.jp/data/diaryarchives.dat?' + timestamp);
});
