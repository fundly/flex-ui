package com.enilsson.elephanttrakker.models.viewclasses
{
	import com.enilsson.vo.ErrorVO;
	
	import mx.collections.ArrayCollection;
	
	[Bindable]	
	public class MyDetailsViewClass
	{
		public function MyDetailsViewClass()
		{
		}
		
		public var layout:Object;
		public var details:ArrayCollection;

		public var formProcessing:Boolean = false;
		public var isSubmitting:Boolean = false;
		public var detailsError:ErrorVO;
		public var firstLoginError:ErrorVO;
		
		public var errorVO:ErrorVO;
		public var onClose:Function;		
		
		public var oldPWD:String;
		public var newPWD:String;
		
		public var pwdUpdate:Boolean = false;

		public var formVariables:Object = new Object();
		public var contact_details:Object = new Object();
		public var contact_id:Number = 0;
		
		public var welcomeScreen:Boolean = false;
		public var loginBoxState:int = 0;
		
		public var vStackIndex:int;
	}
}