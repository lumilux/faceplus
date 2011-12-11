
// ActionScript file
import com.facebook.graph.FacebookDesktop;
import com.facebook.graph.data.Batch;
import com.facebook.graph.net.FacebookBatchRequest;

import flash.events.*;

import mx.collections.ArrayList;
import mx.events.*;
import mx.events.FlexEvent;
import User;


public var users:ArrayList = new ArrayList();			//holds the User objects that represent search results

private var ids:ArrayList = new ArrayList();			//holds the ids of search results, used for internal book keeping

public static var APP_ID:String = "283561771688383";	//application id
public static var ACCESS_TOKEN:String;					//the access token that is generated when the user logs in, used for makin batch requests


private static var USER_ID:String = "";					//user id of the logged in user, might be needed for fetching his/her image 

private var i:int;										//variable used in many loops, not a good idea to be made global, but bare with it
private var userListStart:int;

private var  reqMutualsBatch:Batch;						//this is used to store the requests to get mutuals
private var searchUserCallback:Function;				//this is the callback to be called when the last asynchromous call completes
														//in searchUser()


protected function windowedapplication1_creationCompleteHandler(event:FlexEvent):void
{
	// TODO Auto-generated method stub

	FacebookDesktop.init("283561771688383");
	
}

protected function loginHandler(success:Object,fail:Object):void
{
	if(success)
	{
		//currentState="loggedin";
		//nameLbl.text = success.user.name;
		//userImg.source = FacebookDesktop.getImageUrl(success.uid, "small");
		//birthdayLbl.text = success.user.birthday;
		
		//FacebookDesktop.api("/me/statuses", getStatusHandler);
		
		//var searchMethod:String = "/search?q=nikhil%20mhatre&type=user&";
		
		//set the access token and the user id for future use
		ACCESS_TOKEN = success.accessToken;
		USER_ID = success.uid;
		trace("login successful!");
		this.currentState = "loggedin";
		
		//this is just a test
		//searchUser("Jim", 0, dummySampleCallback);
		
	}
}

public function dummySampleCallback():void
{
	trace(users);
}

//this method searches the facebook graph for given string (20 at a time)
//and populates the users arraylist with Users objects
//that hold the search results.
//
//This function always adds to the users list, so to get the previous results just traverse back up the users list
//
//usage sample: searchUser("Jim", 0, firstcallback) will fetch the first 20 results and the firstcallback method will be called
//				searchUser("Jim", 1, secondcallback) will fetch the next 20 results and secondcallback will be called

protected function searchUser(searchString:String, offset:int, callback:Function):void
{
	var offsetTxt:String;
	offsetTxt = String(offset*20);
	
	//if offset is 0, it means it is a fresh search
	//so clear the users list
	if(offset == 0)
	{
		users = new ArrayList();
	}
	//assign the call back
	searchUserCallback = callback;
	
	var searchMethod:String = "/search?q=" + searchString + "&type=user&format=json&limit=20&offset="+offsetTxt+"&";
	FacebookDesktop.api(searchMethod, searchResultsHandler);
	
}

//the handler to 
protected function searchResultsHandler(success:Object, failure:Object):void
{
	if(success)
	{
		trace("Successful");
		var i:int;
		
		//empty the list that contains the ids
		ids.removeAll();
		
		for(i = 0; i < success.length; i++)
		{					
			ids.addItem(success[i].id);
		}
		
		//this batch has requests to get user info
		var  reqUserInfoBatch:Batch = new Batch();
		
		reqMutualsBatch = new Batch();
		
		
		//for each user id, fetch the user data by submitting a batch request
		for(i = 0; i < ids.length; i++)
		//for(i=0;i<5;i++);
		{
			
			var getUserById:String = "/" + ids.getItemAt(i);
			
			reqUserInfoBatch.add(getUserById);
			
			var getMutualsById:String = "/me/mutualfriends/" + ids.getItemAt(i);
			reqMutualsBatch.add(getMutualsById);						
		}
		
		var userInfoBatchRequest:FacebookBatchRequest = new FacebookBatchRequest(reqUserInfoBatch, userDataHandler);
		userInfoBatchRequest.call(ACCESS_TOKEN);
		
	}
}

protected function userDataHandler(success:Object): void
{
	if(success && success.data)
	{
		userListStart = (users.length == 0 ) ? 0 : users.length - 1;
		var count:int;
		
		for(count = 0; count < success.data.length; count++)
		{
			var u:User = new User();
			u.name = success.data[count].body.name;		//name is always there
			
			u.id = success.data[count].body.name;		//save the id
			
			
			if(success.data[count].body.location)		//if location exists , add it
			{
				u.location = success.data[count].body.location.name;
			}
			else
			{
				u.location = "";
			}
						
			readEducation(success.data[count].body, u);	//read the education json obj
			
			//add the new user to the list
			users.addItem(u);
			
		}
		
		trace("users length: "+users.length);
		
		//now for each id make a request to get mutuals
		var reqMutualsBatchRequest:FacebookBatchRequest = new FacebookBatchRequest(reqMutualsBatch, mutualFriendsHandler);
		reqMutualsBatchRequest.call(ACCESS_TOKEN);
		
	}
	
}

private function readEducation(userBody:Object, user:User): void
{
	if(userBody.education != null)
	{
		var j:int;
		for(j = 0; j < userBody.education.length; j++)
		{
			var s:School = new School();
			s.name = userBody.education[j].school.name;		//school will always be there
			s.type = userBody.education[j].type;
						
			if( userBody.education[j].year != null )
			{
				s.year = userBody.education[j].year.name;		//year may always not be there..so check if this is null
			}
			else
			{
				s.year = "";
			}
						
			//userBody.education.addItem(s);
		}		
	}
}


protected function mutualFriendsHandler(success:Object): void
{
	trace("entering mutual friends");
	if(success.data)
	{
		for( i = userListStart; i < users.length; i++)
		{
			//if(success.data && success.data[i - userListStart] && success.data[i - userListStart].body && success.data[i - userListStart].body.data && success.data[i - userListStart].body.data.length) {
				trace("success.data is "+success.data);
				trace("element is "+success.data[i - userListStart]);
				trace("body is :"+success.data[i - userListStart].body);
				trace("body.data is: "+success.data[i - userListStart].body.data);
				users.getItemAt(i).mutuals = success.data[i - userListStart].body.data.length;
			//} else {
			//	trace("something was undefined!");
			//}
		}
		
		//the users list is completely populated at this point
		//call the callback function
		searchUserCallback();
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

protected function login(event:MouseEvent):void
{
	FacebookDesktop.login(loginHandler, ["user_birthday", "read_stream",
										 "user_location", "friends_location",
										 "user_education_history", "friends_education_history",
										 "user_hometown", "friends_hometown"]);
}

protected function logout(event:MouseEvent):void
{
	// TODO Auto-generated method stub
	FacebookDesktop.logout();
	this.currentState="loggedout";
	
}



