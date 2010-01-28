package com.enilsson.elephantadmin.events.modules.app_options
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class GetUsersEvent extends CairngormEvent
	{
		public static const GET_USERS : String = "getUsers";
		
		public var currentPage : int;
		
		public function GetUsersEvent( currentPage:int=0 ) {
			super( GET_USERS, false, false );
			this.currentPage = currentPage;
		}
		
		override public function clone():Event {
			return new GetUsersEvent( currentPage );
		}
		
	}
}