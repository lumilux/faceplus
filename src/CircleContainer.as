package {
	import flash.display.Shape;
	
	import mx.collections.*;
	import mx.core.UIComponent;
	import mx.events.CollectionEvent;
	
	import spark.components.Label;
	
	public class CircleContainer extends UIComponent {
		public var radius:int;
		public var cColor:uint = 0xEEEEEE;
		
		private var circle:Shape;
		[Bindable]
		private var items:ArrayList;
		
		public function CircleContainer(x:int, y:int, radius:int) {
			this.x = x;
			this.y = y;
			this.radius = radius;
			items = new ArrayList();
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
			circle.graphics.lineStyle(1, 0x6666FF, 0.5);
			circle.graphics.drawCircle(this.x, this.y, this.radius);
			circle.graphics.endFill();
			addChild(circle);
			drawItems();
		}
		
		private function drawPolarUser(user:User, theta:Number) {
			var _x = this.x + this.radius * Math.cos(theta);
			var _y = this.y + this.radius * Math.sin(theta);
			drawUser(user, _x, _y);
		}
		
		private function drawUser(user:User, x:int, y:int) {
			var name_lbl = new Label();
			name_lbl.text = user.name;
			name_lbl.move(x, y);
			addChild(name_lbl);
		}
		
		private function drawItems() {
			//TODO: draw objects along circle
			if(items.length == 1) {
				drawUser(items.getItemAt(i) as User, 0, 0);
			} else if (items.length > 1) {
				var theta = 360.0 / items.length;
				for(var i:int = 0; i < items.length; i++) {
					drawPolarUser(items.getItemAt(i) as User, theta);
				}
			}
		}
		
		private function itemsChangeListener(e:CollectionEvent) {
			drawItems();
		}
	}
}