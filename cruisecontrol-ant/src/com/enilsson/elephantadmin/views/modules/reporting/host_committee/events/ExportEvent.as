package com.enilsson.elephantadmin.views.modules.reporting.host_committee.events
{
	import flash.events.Event;

	public class ExportEvent extends Event
	{
		public static const EXPORT_IDS:String = "exportIDs";
		
		public var ids:Array = []
		
		public function ExportEvent(type:String, ids:Array, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.ids = ids;
		}
		
		override public function clone():Event
		{
			return new ExportEvent(type, ids, bubbles, cancelable);
		}
	}
}