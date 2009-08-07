package com.enilsson.elephanttrakker.events.modules.calls_reminders
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class CallsReminders_Event extends CairngormEvent
	{
		static public var EVENT_CR_CALLS_LAYOUT:String = 'cr_calls_layout';
		static public var EVENT_CR_CALLS_LIST:String = 'cr_calls_list';
		static public var EVENT_CR_CALLS_SEARCHCONTACTS:String = 'cr_calls_searchcontacts';
		
		public var e:String;
		public var params:Object;
		
		public function CallsReminders_Event(e:String, params:Object = null)
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
			return new CallsReminders_Event( e, params );
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