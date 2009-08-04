package com.enilsson.elephantadmin.events.session
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class SessionEvent extends CairngormEvent
	{
		static public var GET_SESSION_INFO:String = 'get_session_info';
		static public var END_SESSION:String = 'end_session';
		static public var END_PROXY_SESSION:String = 'end_proxy_session';
		static public var CHECK_SUPERUSER:String = 'check_superuser';
		static public var INIT_SESSION_CHECK:String = 'init_session_check';	
		static public var SESSION_WHEEL:String = 'session_wheel';	
		
		public var e:String;
		public var params:Object
		
		public function SessionEvent(e:String, params:Object=null)
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
			return new SessionEvent(e, params);
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