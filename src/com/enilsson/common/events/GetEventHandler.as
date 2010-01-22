package com.enilsson.common.events
{
	public class GetEventHandler
	{
		public static function handleResult( event : GetEvent, result : Object ) : void {
			if( isValidEvent(event) )
				event.host[event.prop] = result["result"];
		}
		
		private static function isValidEvent( event : GetEvent ) : Boolean {
			return event && event.host  && event.prop && event.host.hasOwnProperty( event.prop );
		}
	}
}