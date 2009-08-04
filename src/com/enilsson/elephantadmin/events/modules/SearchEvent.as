package com.enilsson.elephantadmin.events.modules
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.elephantadmin.vo.SearchVO;
	
	import flash.events.Event;
	
	import mx.rpc.IResponder;

	public class SearchEvent extends CairngormEvent
	{
		public static const SEARCH 	: String = "search";
		public var search 			: SearchVO;
		public var responder 		: IResponder;
		
		public function SearchEvent( search : SearchVO, responder : IResponder )
		{
			super(SEARCH);
			this.search		= search;
			this.responder	= responder;
		}
		
		override public function clone():Event
		{
			return new SearchEvent( search, responder );
		}		
	}
}