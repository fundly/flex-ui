package com.enilsson.elephanttrakker.models.viewclasses
{
	import com.enilsson.vo.ErrorVO;
	
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class MessageCenterViewClass
	{
		public function MessageCenterViewClass()
		{
		}
		
		public var requests:ArrayCollection;
		public var messages:ArrayCollection;
		public var sentMessages:ArrayCollection;
		public var fundraisersSearch:ArrayCollection;	
		public var index:uint;
		public var array:String;
		
		public var fid:int;
		public var fidLabel:String;
		
		public var subject:String;
		public var message:String;

		public var errorVO:ErrorVO;
		public var onClose:Function;
		
		public var isSubmitting:Boolean = false;
		public var isValid:Boolean = false;
		
		public var vindex:uint = 0;
		public var prevVIndex:Number = -1;
		
		public var requestResponse:Object;
	}
}