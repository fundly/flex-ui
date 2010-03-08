package com.enilsson.elephantadmin.events
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephantadmin.vo.UIAccessVO;

	public class UIAccessEvent extends CairngormEvent
	{
		public static const GET_UI_ACCESS_RIGHTS : String = "getUIAccessRights";
		public static const SET_UI_ACCESS_RIGHTS : String = "setUIAccessRights";
		
		public var userId : int;
		public var vo : UIAccessVO;		
		public var nextEvent : CairngormEvent;
		
		public function UIAccessEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}