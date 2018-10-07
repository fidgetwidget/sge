package sge.lib.timeruler;

typedef Marker = {

  var id :UInt;
  var color :UInt;

  var startTime :Float;
  var endTime :Float;
  var elapsedTime :Float;

  var min :Float;
  var max :Float;
  var avg :Float;
  
  var minOffset :Float;
  var maxOffset :Float;
  var offset :Float;


  var samples :Int;

}