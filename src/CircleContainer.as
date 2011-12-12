package {
	import flash.display.Shape;
	
	import mx.collections.*;
	import mx.containers.Canvas;
	import mx.core.UIComponent;
	import mx.events.CollectionEvent;
	
	import spark.components.Label;
	
	public class CircleContainer extends UIComponent {
		public var radius:int;
		public var cColor:uint;
		private var cv:Canvas;
		private var circle:Shape;
		private var borderColor:uint;
		[Bindable]
		private var items:ArrayList;
		
		public function CircleContainer(x:int, y:int, radius:int, color:uint = 0xEEEEEE, borderCol:uint = 0x6666FF) {
			super();
			this.x = x;
			this.y = y;
			this.radius = radius;
			this.cColor = color;
			this.borderColor = borderCol;
			items = new ArrayList();
			//items.addEventListener(CollectionEvent.COLLECTION_CHANGE, itemsChangeListener);
			this.draw();
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
			circle.graphics.lineStyle(1, borderColor, 0.5);
			circle.graphics.drawCircle(this.x, this.y, this.radius);
			circle.graphics.endFill();
			addChild(circle);
		}
		
		private function drawPolarUser(user:User, theta:Number) {
			var _x = this.x + this.radius * Math.cos(theta);
			var _y = this.y + this.radius * Math.sin(theta);
			drawUser(user, _x, _y);
		}
		
		private function drawUser(user:User, x:int, y:int) {
			var name_lbl:Label = new Label();
			name_lbl.text = user.name.replace(" ", "\n");
			name_lbl.move(this.x + x, this.y + y);
			this.parent.addChild(name_lbl);
		}
		
		public function drawItems() {
			//TODO: draw objects along circle
			if(items.length == 1) {
				drawUser(items.getItemAt(i) as User, 0, 0);
			} else if (items.length > 1) {
				var theta = 0.0;
				var delta = 360.0 / items.length;
				for(var i:int = 0; i < items.length; i++) {
					drawPolarUser(items.getItemAt(i) as User, theta);
					theta += delta;
				}
			}
		}
	}
}