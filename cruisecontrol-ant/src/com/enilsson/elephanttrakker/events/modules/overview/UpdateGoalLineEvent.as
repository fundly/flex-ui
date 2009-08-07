package com.enilsson.elephanttrakker.events.modules.overview
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class UpdateGoalLineEvent extends CairngormEvent
	{
		static public var EVENT_UPDATE_GOALLINE:String = 'update_goalline';
		
		public var newGoalLine:String;
		
		public function UpdateGoalLineEvent(newGoalLine:String)
		{
			super( EVENT_UPDATE_GOALLINE );
		
			this.newGoalLine = newGoalLine;
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			return new UpdateGoalLineEvent(newGoalLine);
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