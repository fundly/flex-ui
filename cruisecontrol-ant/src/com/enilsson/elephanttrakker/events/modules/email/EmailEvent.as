package com.enilsson.elephanttrakker.events.modules.email
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class EmailEvent extends CairngormEvent
	{
		static public var EMAIL_CONTACTS:String = 'email_contacts';
		static public var EMAIL_ATTACHMENTS:String = 'email_attachments';
		static public var EMAIL_TEMPLATES:String = 'email_templates';
		static public var EMAIL_SEND_EMAILS:String = 'email_send_emails';
		static public var EMAIL_SENT:String = 'email_sent';
		static public var EMAIL_GET_LOG:String = 'email_get_log';
		
		private var e:String;
		
		public function EmailEvent(e:String)
		{
			this.e = e;
			
			super( e );
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			return new EmailEvent(e);
		}
	}
}