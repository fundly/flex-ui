package com.enilsson.elephanttrakker.models.viewclasses
{
	import com.enilsson.elephanttrakker.vo.ErrorVO;
	
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class InvitationViewClass
	{
		public function InvitationViewClass()
		{
		}
		
		public var formState:String = 'hideMsg';

		public var email:String = '';
		public var fname:String = '';
		public var lname:String = '';
		public var subject:String = '';
		public var message:String = '';
		public var attachment:String;
		public var template_variables:Object = new Object();
		
		public var errorVO:ErrorVO;
		
		public var selectedEmails:Array = new Array();
		
		public var sentList:ArrayCollection = new ArrayCollection()
		public var selectedLogIndex:int = -1;
		
		public var isSubmitting:Boolean = false;
		public var sendingInvitation:Boolean = false;
		public var onClose:Function;
		
	}
}