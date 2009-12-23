package com.enilsson.common.utils
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class DispatchingTimer
	{
		private var _timer : Timer;
		private var _event : CairngormEvent;
		private var _hasListener : Boolean;
		
		public function DispatchingTimer( event : CairngormEvent, delay:Number, repeatCount:int=0)
		{
			_event = event;
			resetTimerValues( delay, repeatCount );
		}
		
		public function start():void
		{
			if( ! _timer ) return;
			
			if( _timer.running ) {
				reset();
				return;
			}
			
			if( ! _hasListener ) {
				_timer.addEventListener(TimerEvent.TIMER, dispatch, false, 0, true);
				_hasListener = true;
			}
			
			_timer.start();
		}
		
		public function stop() : void
		{
			if( ! _timer ) return;
			
			if(_hasListener) {
				_timer.removeEventListener(TimerEvent.TIMER, dispatch);
				_hasListener = false;
			}
			
			_timer.stop();
		}
		
		public function reset() : void
		{
			if( ! _timer ) return;
			_timer.reset();
		}
		
		public function resetTimerValues( delay : Number, repeatCount : int = 0 ) : void {
			var running : Boolean;
			
			if( _timer ) {
				running = _timer.running;
				stop();
				_timer = null;
			}
			_timer = new Timer( delay, repeatCount );
			
			if(running) { 
				start();
			}
		}
		
		public function get running() : Boolean { return _timer && _timer.running; }
		
		private function dispatch( e : TimerEvent ) : void
		{
			if( _event )
			{
				var cEvent : CairngormEvent = _event.clone() as CairngormEvent;
				if( cEvent )
					cEvent.dispatch();
			}
		}
	}
}