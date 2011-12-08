
// ActionScript file
import com.facebook.graph.FacebookDesktop;

import mx.events.*;
import flash.events.*;

protected function windowedapplication1_creationCompleteHandler(event:FlexEvent):void
{
	// TODO Auto-generated method stub
	FacebookDesktop.init("283561771688383", loginHandler);
	
}

protected function loginHandler(success:Object,fail:Object):void
{
	if(success)
	{
		/*currentState="loggedin";
		nameLbl.text = success.user.name;
		userImg.source = FacebookDesktop.getImageUrl(success.uid, "small");
		birthdayLbl.text = success.user.birthday;
		FacebookDesktop.api("/me/statuses", getStatusHandler);*/
		
	}
}

protected function login_clickHandler(event:MouseEvent):void
{
	// TODO Auto-generated method stub
	
}

protected function getStatusHandler(success:Object, failure:Object):void
{
	if(success)
	{
		//statusLbl.text = success[0].message;
	}
}

protected function login():void
{
	FacebookDesktop.login(loginHandler, ["user_birthday", "read_stream"]);
}

protected function logout():void
{
	// TODO Auto-generated method stub
	FacebookDesktop.logout();
	//currentState="loggedout";
	
}