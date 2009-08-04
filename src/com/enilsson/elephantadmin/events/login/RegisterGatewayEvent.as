package com.enilsson.elephantadmin.events.login
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class RegisterGatewayEvent extends CairngormEvent
	{
		static public var EVENT_REGISTER_GATEWAY:String = 'register_gateway';
		
		public var instanceID:uint;
		
		public function RegisterGatewayEvent(_instanceID:uint)
		{
			super(EVENT_REGISTER_GATEWAY);
			
			this.instanceID = _instanceID
		}

		/**
		 * Override clone mehod.
		 */
		override public function clone():Event 
		{
			return new RegisterGatewayEvent(instanceID);
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