package com.enilsson.elephanttrakker.modules.business
{
	import mx.rpc.remoting.mxml.RemoteObject;
	
	public class DelegateFactory
	{
		public static function create( type:int, service : Object ) : Object {
			
			var m : DelegateMap = new DelegateMap();
			var d : Object;
			
			try {
				d = new m[type]( service );
			}
			catch( e : Error ) {
				d = null;
				trace( "Error during delegate instanciation: \n" + e.getStackTrace() );
			}
			
			return d;
		}
	}
}