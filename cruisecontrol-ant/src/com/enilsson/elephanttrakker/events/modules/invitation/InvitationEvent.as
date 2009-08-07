package com.enilsson.elephanttrakker.events.modules.invitation
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class InvitationEvent extends CairngormEvent
	{
		static public var INVITATION_SEND:String = 'invitation_send';
		static public var INVITATION_SENT:String = 'invitation_sent';
		static public var INVITATION_GET_LOG:String = 'invitation_get_log';
		
		private var e:String;
		
		public function InvitationEvent(e:String)
		{
			this.e = e;
			
			super( e );
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			return new InvitationEvent(e);
		}
	}
}