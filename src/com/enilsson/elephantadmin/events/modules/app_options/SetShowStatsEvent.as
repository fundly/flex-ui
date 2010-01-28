package com.enilsson.elephantadmin.events.modules.app_options
{
	import com.adobe.cairngorm.control.CairngormEvent;

	public class SetShowStatsEvent extends CairngormEvent
	{
		public static const SHOW : String = "show";
		public static const HIDE : String = "hide";
		
		public function SetShowStatsEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}