package com.enilsson.elephantadmin.events.main
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class GetGroupsEvent extends CairngormEvent
	{
		static public var EVENT_GET_GROUPS:String = 'get_groups';
		
		public function GetGroupsEvent()
		{
			super( EVENT_GET_GROUPS );
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			return new GetGroupsEvent();
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