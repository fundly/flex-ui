package com.enilsson.elephantadmin.events.modules.app_options
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;

	public class SiteOptionsEvent extends CairngormEvent
	{
		public static const GET_SITE_OPTIONS : String = "getSiteOptions";
		
		public function SiteOptionsEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			return new SiteOptionsEvent( type, bubbles, cancelable );
		}
	}
}