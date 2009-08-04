package com.enilsson.elephantadmin.events.main
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class S3Event extends CairngormEvent
	{
		static public var EVENT_S3:String = 's3_event';
		
		public function S3Event()
		{
			super( EVENT_S3 );
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			return new S3Event();
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