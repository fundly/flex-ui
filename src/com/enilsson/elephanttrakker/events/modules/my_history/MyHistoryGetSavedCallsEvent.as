package com.enilsson.elephanttrakker.events.modules.my_history
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class MyHistoryGetSavedCallsEvent extends CairngormEvent
	{
		static public var EVENT_MYHISTORY_GET_SAVEDCALLS:String = 'myhistory_user_storage';
		
		public var iFrom:int;
		public var iCount:int;
		public var paginate:String;
		public var sort:String;
		
		public function MyHistoryGetSavedCallsEvent(iFrom:int=0, iCount:int=200, paginate:String='', sort:String='')
		{
			super( EVENT_MYHISTORY_GET_SAVEDCALLS );
			
			this.iFrom = iFrom;
			this.iCount = iCount;
			this.paginate = paginate;
			this.sort = sort;
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			return new MyHistoryGetSavedCallsEvent(iFrom, iCount, paginate, sort);
		}
	}
}