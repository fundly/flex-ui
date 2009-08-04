package com.enilsson.elephanttrakker.events
{
	import com.adobe.cairngorm.control.CairngormEvent;

	public class GetVersionEvent extends CairngormEvent
	{
		public static const GET_VERSION : String = "getVersion";
				
		public var nextEvent : CairngormEvent;
		
		public function GetVersionEvent()
		{
			super(GET_VERSION, false, true);
		}
	}
}