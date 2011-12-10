package {
	import flash.display.Shape;
	
	import mx.collections.*;
	import mx.core.UIComponent;
	import mx.events.CollectionEvent;
	
	public class CircleContainer extends UIComponent {
		public var x:int;
		public var y:int;
		public var radius:int;
		public var cColor:uint = 0xDDDDDD;
		
		private var circle:Shape;
		[Bindable]
		private var items:ArrayList;
		
		public function CircleContainer(x:int, y:int, radius:int) {
			this.x = x;
			this.y = y;
			this.radius = radius;
			items.addEventListener(CollectionEvent.COLLECTION_CHANGE, itemsChangeListener);
		}
		
		public function addItem(item:Object) {
			items.addItem(item);
		}
		
		public function clearItems() {
			items.removeAll();
		}
		
		public function setColor(newcolor:uint) {
			this.cColor = newcolor;
		}
		
		public function draw() {
			this.circle = new Shape();
			circle.graphics.beginFill(cColor);
			circle.graphics.drawCircle();
			circle.graphics.endFill();
			addChild(circle);
			drawItems();
		}
		
		private function drawItems() {
			//TODO: draw objects along circle
			if(items.length == 1) {
				
			} else if (items.length > 1) {
				
			}
		}
		
		private function itemsChangeListener(e:CollectionEvent) {
			drawItems();
		}
	}
}