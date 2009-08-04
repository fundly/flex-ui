package com.enilsson.elephanttrakker.events.modules.my_history
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class MyHistoryGetContribsEvent extends CairngormEvent
	{
		static public var EVENT_MYHISTORY_GET_CONTRIBS:String = 'myhistory_get_cc_contribs';
		static public var EVENT_MYHISTORY_GET_CHECK_CONTRIBS:String = 'myhistory_get_check_contribs';
		
		public var iFrom:int;
		public var iCount:int;
		public var paginate:String;
		public var sort:String;
		
		private var e:String;
		
		public function MyHistoryGetContribsEvent(e:String = 'myhistory_get_cc_contribs',iFrom:int=0, iCount:int=200, paginate:String='', sort:String='')
		{
			super(e);
			
			this.e = e;

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
			return new MyHistoryGetContribsEvent(e, iFrom, iCount, paginate, sort);
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