import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class square_watchhandsView extends WatchUi.WatchFace {
  var screenWidth;
  var screenHeight;
  var minutePolygon;
  var hourPolygon;
  var centerX;
  var centerY;
  var size;
  var half_size;

  function initialize() {
    WatchFace.initialize();
  }

  // Load your resources here
  function onLayout(dc as Dc) as Void {
    screenWidth = dc.getWidth();
    screenHeight = dc.getHeight();
    centerX = screenWidth / 2;
    centerY = screenHeight / 2;
    // Calculate largest square that fits in circle
    // The watch screen is a circle with radius screenWidth, assuming screenWidth == screenHeight
    // Size is also 90% of this max width/height
    size = Math.sqrt(Math.pow(screenWidth, 2) / 2) * 0.9;
    half_size = size / 2;

    minutePolygon = [
      [centerX - half_size, centerY - half_size],
      [centerX - half_size * 0.05, centerY - half_size],
      [centerX - half_size * 0.05, centerY],
      [centerX + half_size * 0.05, centerY],
      [centerX + half_size * 0.05, centerY - half_size],
      [centerX + half_size, centerY - half_size],
      [centerX + half_size, centerY + half_size],
      [centerX - half_size, centerY + half_size],
    ];

    // hour hand has half depth of minute hand
    hourPolygon = [
      [centerX - half_size, centerY - half_size],
      [centerX - half_size * 0.05, centerY - half_size],
      [centerX - half_size * 0.05, centerY - half_size / 2],
      [centerX + half_size * 0.05, centerY - half_size / 2],
      [centerX + half_size * 0.05, centerY - half_size],
      [centerX + half_size, centerY - half_size],
      [centerX + half_size, centerY + half_size],
      [centerX - half_size, centerY + half_size],
    ];
  }

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  function onShow() as Void {}

  // Update the view
  function onUpdate(dc as Dc) as Void {
    var today = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
    var colorBG;
    var colorFG;

    // White if day (6am-6pm), black if night (6pm-6am)
    if (today.hour > 6 && today.hour < 18) {
      colorFG = Graphics.COLOR_BLACK;
      colorBG = Graphics.COLOR_WHITE;
    } else {
      colorFG = Graphics.COLOR_WHITE;
      colorBG = Graphics.COLOR_BLACK;
    }
    // fill background color
    dc.setColor(colorFG, colorBG);
    dc.clear();

    // draw minutes hand / square
    var minutesSquareCorners = getCornersForTime(
      minutePolygon,
      today.min / 60.0
    );
    drawPolygon(dc, minutesSquareCorners);

    // draw hours hand / square
    var hour = today.hour;
    if (hour > 12) {
      hour -= 12;
    }
    var hoursSquareCorners = getCornersForTime(
      hourPolygon,
      (hour * 60.0 + today.min) / 720.0
    );
    drawPolygon(dc, hoursSquareCorners);

    // draw center dot
    dc.fillCircle(centerX, centerY, half_size * 0.05);
  }

  function getCornersForTime(polygon, time_fraction) {
    // time_fraction could represent % completion of the current hour (minute hand), or the half of the day (hour hand)
    var angle = Math.toRadians(360 * time_fraction);

    // Rotate points about center coords
    // Prepend/append last/first coords (respectively) so the polygon connects
    var newPolygon = [
      rotatePoint(
        polygon[polygon.size() - 1][0],
        polygon[polygon.size() - 1][1],
        angle
      ),
    ];
    for (var i = 0; i < polygon.size(); i++) {
      newPolygon.add(rotatePoint(polygon[i][0], polygon[i][1], angle));
    }
    newPolygon.add(rotatePoint(polygon[0][0], polygon[0][1], angle));

    return newPolygon;
  }

  function rotatePoint(x, y, angle) {
    var new_x =
      centerX +
      (x - centerX) * Math.cos(angle) -
      (y - centerY) * Math.sin(angle);
    var new_y =
      centerY +
      (x - centerX) * Math.sin(angle) +
      (y - centerY) * Math.cos(angle);

    return [new_x, new_y];
  }

  function drawPolygon(dc, points) {
    // Draw shape as lines between points
    for (var i = 0; i < points.size() - 1; i++) {
      dc.drawLine(
        points[i][0],
        points[i][1],
        points[i + 1][0],
        points[i + 1][1]
      );
    }
  }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() as Void {}

  // The user has just looked at their watch. Timers and animations may be started here.
  function onExitSleep() as Void {}

  // Terminate any active timers and prepare for slow updates.
  function onEnterSleep() as Void {}
}
