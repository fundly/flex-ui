package com.enilsson.elephanttrakker.models.viewclasses
{
	import com.enilsson.vo.ErrorVO;
	
	import mx.collections.ArrayCollection;
	
	[Bindable]	
	public class FirstLoginViewClass
	{
		public function FirstLoginViewClass()
		{
		}
		
		public var layout:Object;
		public var details:ArrayCollection;

		public var formProcessing:Boolean = false;
		public var isSubmitting:Boolean = false;
		
		public var errorVO:ErrorVO;
		
		public var oldPWD:String;
		public var newPWD:String;

		public var formVariables:Object = new Object();
		public var contact_details:Object = new Object();
		public var contact_id:Number = 0;
		
		public var welcomeScreen:Boolean = false;
		public var loginBoxState:int = 0;
		
		public var vStackIndex:int;
	}
}