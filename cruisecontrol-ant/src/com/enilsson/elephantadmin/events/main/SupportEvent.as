package com.enilsson.elephantadmin.events.main
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class SupportEvent extends CairngormEvent
	{
		static public var EVENT_SEND_SUPPORT:String = 'support_send';
		
		public var e:String;
		public var params:Object;
		
		public function SupportEvent(e:String, params:Object)
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