package 
{
	import flash.display.DisplayObject;
	
	import mx.collections.*;

	public class User
	{
		public var name:String;
		public var location:String;
		public var network:String;
		
		public var mutuals:int;
		public var id:String;
		
		public var education:ArrayCollection;
		public var work:ArrayCollection;
		public var drawnElements:ArrayList;
		
		public function User()
		{
			education = new ArrayCollection();
			work = new ArrayCollection();
			drawnElements = new ArrayList();
		}
		
		public function hide() {
			for(var i:int = 0; i < drawnElements.length; i++) {
				drawnElements.getItemAt(i).visible = false;
			}
		}
		
		public function show() {
			for(var i:int = 0; i < drawnElements.length; i++) {
				drawnElements.getItemAt(i).visible = true;
			}
		}
	}
	
	
}