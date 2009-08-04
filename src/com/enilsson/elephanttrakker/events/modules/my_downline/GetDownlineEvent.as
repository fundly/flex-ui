package com.enilsson.elephanttrakker.events.modules.my_downline
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class GetDownlineEvent extends CairngormEvent
	{
		static public var EVENT_GET_DOWNLINE:String = 'get_downline';
		static public var EVENT_GET_PARENTS:String = 'get_parents';
		
		public var e:String;
		public var userID:Number;
		public var nodeLevels:int;
		
		public function GetDownlineEvent( e:String, userID:Number, nodeLevels:int=4 )
		{
			super( e );
			
			this.e = type;
			this.userID = userID;
			this.nodeLevels = nodeLevels
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			return new GetDownlineEvent( e, userID, nodeLevels );
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