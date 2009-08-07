package com.enilsson.elephanttrakker.events.modules.call_logging
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class CallLoggingAutoCompleteEvent extends CairngormEvent
	{
		static public var EVENT_CL_AUTOCOMPLETE:String = 'cl_autocomplete';
		static public var EVENT_SEARCH_LABEL:String = 'cl_search_label';
		
		public var e:String;
		public var params:Object;
		
		public function CallLoggingAutoCompleteEvent(e:String, params:Object = null)
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
			return new CallLoggingAutoCompleteEvent( e, params );
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