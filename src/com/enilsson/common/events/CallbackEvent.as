package com.enilsson.common.events
{
	import flash.events.Event;

	public class CallbackEvent extends Event
	{
		public var callback : Function;
		
		public function CallbackEvent(type:String, callback:Function=null, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			this.callback = callback;
		}
		
		override public function clone() : Event {
			return new CallbackEvent(type, callback, bubbles, cancelable );
		}
		
	}
}