package com.enilsson.elephanttrakker.events.modules.resources
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class ResourcesEvent extends CairngormEvent
	{
		static public var EVENT_RESOURCES:String = 'resources';
		
		public function ResourcesEvent()
		{
			super( EVENT_RESOURCES );
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			return new ResourcesEvent();
		}
	}
}