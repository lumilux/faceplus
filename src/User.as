package 
{
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
		
		public function User()
		{
			education = new ArrayCollection();
			work = new ArrayCollection();
		}
	}
	
	
}