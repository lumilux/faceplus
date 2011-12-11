
// ActionScript file

import User;

import com.facebook.graph.FacebookDesktop;
import com.facebook.graph.data.Batch;
import com.facebook.graph.net.FacebookBatchRequest;

import flash.events.*;

import mx.collections.ArrayCollection;
import mx.collections.ArrayList;
import mx.controls.Label;
import mx.core.UIComponent;
import mx.events.*;
import mx.events.FlexEvent;

import spark.collections.Sort;
import spark.collections.SortField;
import spark.components.Label;

public var users:ArrayList = new ArrayList();			//holds the User objects that represent search results
public var ids:ArrayList = new ArrayList();			//holds the ids of search results, used for internal book keeping
public var friendIds:ArrayList = new ArrayList();
//the four lists 
public var friends:ArrayList = new ArrayList();
public var inner:ArrayList = new ArrayList();
public var outer:ArrayList = new ArrayList();
public var noMutuals:ArrayList = new ArrayList();

//the four pagination lists
public var friendsPageIndex:ArrayList = new ArrayList();
public var innerCirclePageIndex:ArrayList = new ArrayList();
public var outerCircelpageIndex:ArrayList = new ArrayList();
public var noMutualsPageIndex:ArrayList = new ArrayList();

public static var APP_ID:String = "283561771688383";			//application id
public static var ACCESS_TOKEN:String;					//the access token that is generated when the user logs in, used for makin batch requests


private static var USER_ID:String = "";					//user id of the logged in user, might be needed for fetching his/her image 
private static var LAST_OFFSET:int;
private static var SEARCH_STRING:String = "";

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
			
			u.id = success.data[count].body.id;		//save the id
			
			
			if(success.data[count].body.location)		//if location exists , add it
			{
				u.location = success.data[count].body.location.name;
			}
			else
			{
				u.location = "";
			}
			
			readEducation(success.data[count].body, u);	//read the education json obj
			
			readWorkPlace(success.data[count].body, u); //
			
			
			//add the new user to the list
			users.addItem(u);
			
		}
		
		trace(users.length);
		
		//now for each id make a request to get mutuals
		var reqMutualsBatchRequest:FacebookBatchRequest = new FacebookBatchRequest(reqMutualsBatch, mutualFriendsHandler);
		reqMutualsBatchRequest.call(ACCESS_TOKEN);
		
	}
	
}

private function readWorkPlace(userBody:Object, user:User): void
{
	if(userBody.work)
	{
		var j:int;
		for(j = 0; j < userBody.work.length; j++)
		{
			var w:Work = new Work();
			
			w.employerName = userBody.work[j].employer.name;
			
			userBody.work[j].location ? w.location = userBody.work[j].location : w.location = "" ;
			
			userBody.work[j].position ? w.position = userBody.work[j].position : w.position = "" ;
			
			userBody.work[j].start_date == "0000-00" ? w.startDate = "" : w.startDate = userBody.work[j].start_date;
			
			userBody.work[j].end_date == "0000-00" ? w.endDate = "" : w.endDate = userBody.work[j].end_date;
			
			user.work.addItem(w);
			
		}
	}
}

private function readEducation(userBody:Object, user:User): void
{
	if(userBody.education != null)
	{
		var j:int;
		user.education = new ArrayCollection();
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
			
			user.education.addItem(s);
		}		
	}
}


protected function mutualFriendsHandler(success:Object): void
{
	if(success.data)
	{
		for( i = userListStart; i < users.length; i++)
		{
			users.getItemAt(i).mutuals = success.data[i - userListStart].body.data.length;
		}
		
		
		//at this point get ur friends..and populate a list
		FacebookDesktop.api("/me/friends/", populateFriends);
	}
	
}

protected function populateFriends(success:Object, failure:Object):void
{
	if(success)
	{
		var j:int ;//= success.data.length;
		for( j = 0; j < success.length; j++)
		{
			friendIds.addItem(success[j].id);
		}
	}
	
	//now we have the ids of friends...so i can tell..who are friends and who are not
	makeLists();
	
}

protected function makeLists(): void
{
	var j:int;
	var nonFriends:ArrayCollection = new ArrayCollection();
	for(j = 0; j < users.length; j++)
	{
		var id:String = users.getItemAt(j,0).id;
		if(friendIds.getItemIndex(id) != -1)
		{
			//add this user to friend lists
			friends.addItem(users.getItemAt(j,0));
		}
		else
		{
			nonFriends.addItem(users.getItemAt(j,0));
		}
	}
	
	//trace(friends);
	//trace(nonFriends);
	
	//take the non friends..loop over , find the ones who have zero mutuals
	//and move them to non mutuals list
	var nonZeroMutuals:ArrayCollection = new ArrayCollection();
	for(j = 0; j < nonFriends.length; j++)
	{
		if( nonFriends.getItemAt(j,0).mutuals == 0)
		{
			noMutuals.addItem(nonFriends.getItemAt(j,0));
		}
		else
		{
			nonZeroMutuals.addItem(nonFriends.getItemAt(j,0));
		}
	}
	
	//trace(nonZeroMutuals);
	
	//now sort the nonzero mutuals based on the mutuals 
	var userSort:spark.collections.Sort = new spark.collections.Sort();
	userSort.fields = [new spark.collections.SortField("mutuals", true)];					//the sort is based on the mutuals field
	nonZeroMutuals.sort = userSort;
	nonZeroMutuals.refresh();
	
	var innerCirceLimit:int = Math.ceil(0.33 * nonZeroMutuals.length);	//get the top 33% of nonzero mutuals that will be in the inner circle
	
	for(j = 0; j < innerCirceLimit; j++)
	{
		inner.addItem(nonZeroMutuals.getItemAt(j,0));
	}
	for( ; j < nonZeroMutuals.length; j++)
	{
		outer.addItem(nonZeroMutuals.getItemAt(j,0));
	}
	
	//at this point all the lists are correctly populated
	//so set the new page incdices
	
	
	trace("Friends" + friends);
	trace("Inner Circle" + inner);
	trace("Outer Circle" + outer);
	trace("No Mutuals" + noMutuals);
	
	updatePageIndex(friendsPageIndex, friends.length - 1);
	updatePageIndex(innerCirclePageIndex, inner.length - 1);
	updatePageIndex(outerCircelpageIndex, outer.length - 1);
	updatePageIndex(noMutualsPageIndex, noMutuals.length - 1);				
	
	//make the callback	
	searchUserCallback();
}
//
private function updatePageIndex(pageIndexList:ArrayList, newIndex:int): void
{
	//get the old index
	if(pageIndexList.length == 0)
	{
		if(newIndex == -1)
			pageIndexList.addItem({start:-1, end:-1});
		else
			pageIndexList.addItem({start:0, end:newIndex});
	}
	else
	{
		//get the last element
		var lastElement:Object = pageIndexList.getItemAt(pageIndexList.length - 1);
		
		var oldIndex:int = lastElement.end;
		
		pageIndexList.addItem({start:oldIndex, end:newIndex});
	}
}

//this method searches the facebook graph for given string (20 at a time)
//and populates the users arraylist with Users objects
//that hold the search results.
//
//This function always adds to the users list, so to get the previous results just traverse back up the users list
//
//This method now will also populate the four lists namely friends, innerCircle, outerCircle, noMutuals
//
//Also the four pagination lists will be populated viz friendsPageIndex, etc. A list for each circle so to say .
//Each element of the pagination have the form {start:int, end:int}
//indicating start index and end index for a page
//
//usage sample: searchUser("Jim", 0, firstcallback) will fetch the first 20 results and the firstcallback method will be called
//				searchUser("Jim", 1, secondcallback) will fetch the next 20 results and secondcallback will be called
protected function searchUser(searchString:String, offset:int, callbackarg:Function):void
{
	LAST_OFFSET = offset;
	
	var offsetTxt:String;
	offsetTxt = String(offset*20);
	
	//if offset is 0, it means it is a fresh search
	//so clear the users list
	if(offset == 0)
	{
		//
		users.removeAll();
		
		//clear the existing circle Lists
		inner.removeAll();
		outer.removeAll();
		friends.removeAll();
		noMutuals.removeAll();
		
		//clear all the pagination lists
		innerCirclePageIndex.removeAll();
		outerCircelpageIndex.removeAll();
		friendsPageIndex.removeAll();
		noMutualsPageIndex.removeAll();
		
		SEARCH_STRING = searchString;
	}
	
	
	//assign the argument callback
	searchUserCallback = callbackarg;
	
	//create the search method
	// type   = user
	// format = json
	// limit  = 20   .....we restrict to 20 because we use these results to create batch requests...and FB restricts the batch requests to 20
	// offset = as provided by the user
	var searchMethod:String = "/search?q=" + searchString + "&type=user&format=json&limit=20&offset="+offsetTxt+"&";
	FacebookDesktop.api(searchMethod, searchResultsHandler);
	
}

//returns the next results for the current search string
protected function nextResults(callback:Function):void
{
	searchUser(SEARCH_STRING, LAST_OFFSET + 1, callback);
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
					     "user_work_history","friends_work_history",
					     "user_hometown", "friends_hometown"]);
}

protected function logout(event:MouseEvent):void
{
	// TODO Auto-generated method stub
	FacebookDesktop.logout();
	this.currentState="loggedout";
	
}



