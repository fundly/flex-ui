package com.enilsson.elephantadmin.events.popups
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class DownlineEvent extends CairngormEvent
	{
		static public var GET_DOWNLINE:String = 'get_downline';		
		
		public var e:String;
		public var params:Object
		
		public function DownlineEvent(e:String, params:Object=null)
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
			return new DownlineEvent(e, params);
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