package;

import haxe.*;
import openfl.*;
import openfl.display.*;
import openfl.geom.*;
import openfl.events.*;

class Item extends Sprite {
  public static var ITEM_TYPES:Array<{name:String, price:Int}>;

  public static function addItemTypes():Void {
    ITEM_TYPES = Json.parse(Assets.getText("assets/data/items.json"));
  }

  public var itemName:String;
  public var price:Int;
  private var image:BitmapData;
  private var template:Bool;
  private var room:Room;
  private var tooltip:Tooltip;
  private var startX:Float;
  private var startY:Float;

  public function new (itemName2:String, price2:Int, template2:Bool, room2:Room) {
    super ();
    itemName = itemName2;
    price = price2;
    template = template2;
    room = room2;
    buttonMode = template;
    image = Assets.getBitmapData('assets/images/$itemName.png');
    addChild(new Bitmap(scaleBitmap(image, template)));
    if (template) {
      addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
      addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
      addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
      addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
    }
  }

  private function scaleBitmap(image:BitmapData, template:Bool):BitmapData {
    var scale:Float = Lib.current.stage.stageWidth / 8 / image.width;
    var matrix:Matrix = new Matrix();
    var scaledImage:BitmapData =
      new BitmapData(Math.floor(image.width * scale),
                     Math.floor(image.height * scale),
                     true, 0x000000);
    matrix.scale(scale, scale);
    scaledImage.draw(image, matrix, null, null, null, true);
    return scaledImage;
  }

  private function onMouseOver(event:Event):Void {
    tooltip = new Tooltip('Price: $$$price');
    room.addChild(tooltip);
  }

  private function onMouseOut(event:Event):Void {
    room.removeChild(tooltip);
    tooltip = null;
  }

  private function onMouseDown(event:Event):Void {
    if (room.canAfford(this)) {
      room.removeChild(tooltip);
      tooltip = null;
      startX = x;
      startY = y;
      startDrag();
    }
  }

  private function onMouseUp(event:Event):Void {
    if (room.canAfford(this)) {
      stopDrag();
      var newItem:Item = new Item(itemName, price, false, room);
      newItem.x = x;
      newItem.y = y;
      x = startX;
      y = startY;
      room.purchase(newItem);
    }
  }
}
