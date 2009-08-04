package com.enilsson.elephantadmin.events.main
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;
	
	import mx.containers.ViewStack;

	public class ViewStateEvent extends CairngormEvent
	{
		static public var EVENT_VIEW_STATE:String = 'view_state';
		
		public var viewstack:ViewStack;
		
		public function ViewStateEvent(vstack:ViewStack)
		{
			super( EVENT_VIEW_STATE );
			
			this.viewstack = vstack;
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			return new ViewStateEvent(this.viewstack);
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