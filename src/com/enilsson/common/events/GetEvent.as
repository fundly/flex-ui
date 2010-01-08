package com.enilsson.common.events
{
	import flash.events.Event;

	public class GetEvent extends Event
	{
		public var host	: Object;
		public var prop		: String;
		
		public function GetEvent(type:String, host : Object, prop : String, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);

			this.host = host;
			this.prop = prop; 
		}
		
		override public function clone() : Event {
			return new GetEvent( type, host, prop, bubbles, cancelable );
		}
		
	}
}