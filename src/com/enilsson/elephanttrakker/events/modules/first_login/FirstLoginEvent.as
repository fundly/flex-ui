package com.enilsson.elephanttrakker.events.modules.first_login
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class FirstLoginEvent extends CairngormEvent
	{
		static public var FIRSTLOGIN_UPSERTCONTACT:String 		= 'firstlogin_upsertcontact';
		static public var FIRSTLOGIN_UPSERTDETAILS:String 		= 'firstlogin_upsertdetails';
		static public var FIRSTLOGIN_CHANGEPWD:String 			= 'firstlogin_changepwd';
		static public var FIRSTLOGIN_PASSWORD_CHANGED:String 	= 'firstlogin_password_changed';	
		static public var FIRSTLOGIN_LOGGEDIN:String			= 'firstlogin_loggedin';	
		
		public var e:String;
		public var params:Object;
		
		public function FirstLoginEvent( e:String, params:Object=null )
		{
			this.e = e;
			this.params = params;
			
			super( e );
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			return new FirstLoginEvent( e, params );
		}
	}
}