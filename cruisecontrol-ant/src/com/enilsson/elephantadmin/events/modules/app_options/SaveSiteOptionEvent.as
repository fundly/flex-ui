package com.enilsson.elephantadmin.events.modules.app_options
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephantadmin.views.modules.app_options.model.SiteOption;
	
	import flash.events.Event;

	public class SaveSiteOptionEvent extends CairngormEvent
	{
		public static const SAVE_SITE_OPTION: String = "saveSiteOption";
		
		public var option 	: SiteOption;
		public var callback : Function;
		
		public function SaveSiteOptionEvent(type:String, option : SiteOption, callback : Function, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.option = option;
			this.callback = callback;
		}
		
		override public function clone():Event
		{
			return new SaveSiteOptionEvent( type, option, callback, bubbles, cancelable );
		}
		
	}
}