package com.enilsson.elephanttrakker.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	/**
	 * Event fired when the url is changed, either manually or by the forward/back buttons
	 */
	public class URLChangeEvent extends CairngormEvent
	{
		public static const EVENT_URL_CHANGE:String="URLChange";
		
		public function URLChangeEvent()
		{
			super(EVENT_URL_CHANGE);
		}
		
		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			return new URLChangeEvent();
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