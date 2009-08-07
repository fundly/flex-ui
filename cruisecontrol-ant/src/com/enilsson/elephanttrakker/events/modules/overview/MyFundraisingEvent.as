package com.enilsson.elephanttrakker.events.modules.overview
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class MyFundraisingEvent extends CairngormEvent
	{
		static public var EVENT_MY_FUNDRAISING:String = 'my_fundraising';
		
		public function MyFundraisingEvent()
		{
			super( EVENT_MY_FUNDRAISING );
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			return new MyFundraisingEvent();
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