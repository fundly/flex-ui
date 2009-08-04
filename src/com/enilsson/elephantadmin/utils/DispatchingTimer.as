package com.enilsson.elephantadmin.utils
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class DispatchingTimer extends Timer
	{
		private var _event : CairngormEvent;
		private var _hasListener : Boolean;
		
		public function DispatchingTimer( event : CairngormEvent, delay:Number, repeatCount:int=0)
		{
			super(delay, repeatCount);
			_event = event;
		}
		
		override public function start():void
		{
			if(! _hasListener ) {
				addEventListener(TimerEvent.TIMER, dispatch);
				_hasListener = true;
			}
			super.start();
		}
		
		override public function stop() : void
		{
			if(_hasListener) {
				removeEventListener(TimerEvent.TIMER, dispatch);
				_hasListener = false;
			}
			super.stop();
		}
		
		public function restart() : void
		{
			stop();
			start();
		}
		
		private function dispatch( e : TimerEvent ) : void
		{
			if(_event && running) {
				var cEvent : CairngormEvent = _event.clone() as CairngormEvent;
				if( cEvent )
					cEvent.dispatch();
			}
		}
	}
}