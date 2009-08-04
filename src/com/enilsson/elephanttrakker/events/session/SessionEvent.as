package com.enilsson.elephanttrakker.events.session
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class SessionEvent extends CairngormEvent
	{
		static public var GET_SESSION_INFO:String = 'get_session_info';
		
		private var e:String;
		public var obj:Object;
		
		public function SessionEvent(e:String = 'get_session_info', obj:Object = null)
		{
			this.e = e;
			this.obj = obj;
			
			super( e, obj );
		}


		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			return new SessionEvent(e,obj);
		}
	}
}