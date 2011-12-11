package 
{
	import mx.collections.ArrayList;

	public class User
	{
		public var name:String;
		public var location:String;
		public var network:String;
		
		public var mutuals:int;
		public var id:String;
		
		public var education:ArrayList;
		
		public function User()
		{
			education = new ArrayList();
		}
	}
	
	
}