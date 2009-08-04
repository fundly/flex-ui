package com.enilsson.elephanttrakker.events.main
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class GetRSSEvent extends CairngormEvent
	{
		static public var EVENT_GET_RSS:String = 'get_rss';
		static public var EVENT_SEND_EMAIL:String = 'send_rss_email';
		
		public var e:String;
		public var params:Object;
		
		public function GetRSSEvent(e:String, params:Object = null)
		{
			super( e );
			this.e = e;
			this.params = params;
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			return new GetRSSEvent(e, params);
		}
		

	}
}