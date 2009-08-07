package com.enilsson.elephanttrakker.events.modules.overview
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class AnnouncementsEvent extends CairngormEvent
	{
		static public var EVENT_ANNOUNCEMENTS:String = 'announcements';
		
		public function AnnouncementsEvent()
		{
			super( EVENT_ANNOUNCEMENTS );
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			return new AnnouncementsEvent();
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