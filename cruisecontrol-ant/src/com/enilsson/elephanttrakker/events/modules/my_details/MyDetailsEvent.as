package com.enilsson.elephanttrakker.events.modules.my_details
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class MyDetailsEvent extends CairngormEvent
	{
		static public var MYDETAILS_GETDATA:String = 'mydetails_getdata';
		static public var MYDETAILS_GETLAYOUT:String = 'mydetails_getlayout';
		static public var MYDETAILS_UPSERT:String = 'mydetails_upsert';
		static public var MYDETAILS_CHANGE_EMAIL:String = 'mydetails_change_email';
		static public var MYDETAILS_CHANGE_PWD:String = 'mydetails_change_pwd';
		static public var MYDETAILS_PASSWORD_CHANGED:String = 'mydetails_password_changed';
		static public var MYDETAILS_FIRSTLOGIN:String = 'mydetails_firstlogin';
		static public var MYDETAILS_ADD_FIRST_CONTACT:String = 'mydetail_add_first_contact';
		static public var MYDETAILS_FIRSTLOGIN_CLOSE:String = 'mydetails_firstlogin_close';
		static public var MYDETAILS_UPSERT_CONTACT:String = 'mydetails_upsert_contact';
		
		
		public var e:String;
		public var params:Object;
		
		public function MyDetailsEvent( e:String, params:Object=null )
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
			return new MyDetailsEvent( e, params );
		}
	}
}