package com.enilsson.elephanttrakker.events.main
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class SupportEvent extends CairngormEvent
	{
		static public var EVENT_SEND_SUPPORT:String = 'support_send';
		static public var MESSAGE_SENT:String = 'support_message_sent';
		
		public var e:String;
		public var params:Object;
		
		public function SupportEvent(e:String, params:Object = null)
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
			return new SupportEvent(e,params);
		}
		
	}
}