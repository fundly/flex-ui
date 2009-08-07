package com.enilsson.elephanttrakker.events.modules.call_logging
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class CallLoggingEvent extends CairngormEvent
	{
		static public var EVENT_CONTACT:String = 'call_logging_loadcontact';
		static public var SEND_THANK_YOU:String = 'call_logging_thankyou';
		static public var EVENT_PLEDGE:String = 'call_logging_loadpledge';
		
		public var e:String;
		public var params:Object;
		
		public function CallLoggingEvent(e:String, params:Object = null)
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
			return new CallLoggingEvent(e,params);
		}
	}
}