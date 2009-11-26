package com.enilsson.elephanttrakker.events.modules.my_history
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephanttrakker.vo.SearchVO;
	
	import flash.events.Event;

	public class MyHistorySearchEvent extends CairngormEvent
	{
		static public var EVENT_SEARCH_MYHISTORY:String = 'search_myhistory';

		public var search:SearchVO;
		
		public function MyHistorySearchEvent(search:SearchVO)
		{
			super( EVENT_SEARCH_MYHISTORY );
			this.search = search;
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			return new MyHistorySearchEvent(search);
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