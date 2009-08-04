package com.enilsson.elephanttrakker.events.modules.my_history
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class MyHistoryGetPledgesEvent extends CairngormEvent
	{
		static public var EVENT_MYHISTORY_GET_PLEDGES:String = 'myhistory_getpledges';
		
		public var iFrom:int;
		public var iCount:int;
		public var paginate:String;
		public var sort:String;
		public var where:Object;
		
		public function MyHistoryGetPledgesEvent(iFrom:int=0, iCount:int=200, paginate:String='', sort:String='', where:Object=null)
		{
			super( EVENT_MYHISTORY_GET_PLEDGES );
			
			this.iFrom = iFrom;
			this.iCount = iCount;
			this.paginate = paginate;
			this.sort = sort;
			this.where = where;
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			return new MyHistoryGetPledgesEvent(iFrom, iCount, paginate, sort, where);
		}
		
		/**
		 * Override copyFrom method to get a copy of this event.
		 */
		public function copyFrom(src:Event):Event 
		{	
			return this;
		}
		
		/**
		 * String representation of class.
		 */
		override public function toString():String 
		{	
			return super.toString();
		}
		
	}
}