package com.enilsson.common.utils
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	import mx.core.Application;
	
	public class DispatcherFactory
	{
		private static var _dispatchers : Dictionary = new Dictionary( true );
		
		public static function getDispatcher( context : String ) : IEventDispatcher {
			if( context == null ) return;
			
			var d : IEventDispatcher = _dispatchers[context] as IEventDispatcher;
			
			if( d == null ) {
				d = _dispatchers[context] = new EventDispatcher();
			}
			
			return d;			
		}
		
		public static function destroyDispatcher( context : String ) : Boolean {
			if( context == null ) return;
			
			_dispatchers[context] = null;			
			delete _dispatchers[context];	
		}
		
	}
}