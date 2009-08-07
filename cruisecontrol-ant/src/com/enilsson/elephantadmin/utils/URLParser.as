package com.enilsson.elephantadmin.utils
{
	import com.enilsson.elephantadmin.events.URLChangeEvent;
	import mx.events.BrowserChangeEvent;
	
	public class URLParser
	{
		public static function parse( e : BrowserChangeEvent ) : void 
		{
			new URLChangeEvent().dispatch();	
		}
	}
}