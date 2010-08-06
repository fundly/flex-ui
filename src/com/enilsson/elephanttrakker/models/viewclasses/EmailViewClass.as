package com.enilsson.elephanttrakker.models.viewclasses
{
	import com.enilsson.vo.ErrorVO;
	
	import mx.collections.ArrayCollection;
	
	/**
	 * A collection of data for the Email module
	 */
	[Bindable]
	public class EmailViewClass
	{
		public function EmailViewClass()
		{
		}
		public var effectContactList:String = 'moveOut';
		public var contactRunning:Boolean = false;
		public var contacts:ArrayCollection = new ArrayCollection();
		public var email_attachments:ArrayCollection = new ArrayCollection();
		public var templates:ArrayCollection = new ArrayCollection();
		public var templateID:int;

		// list of emails to be send
		public var emails:String;
		public var bccEmail:Boolean;

		//  subject
		public var subject:String;
		//  message
		public var message:String;

		//  message
		public var attachment:String;
		
		public var errorVO:ErrorVO;
		
		public var selectedEmails:Array = new Array();
		
		public var isSubmitting:Boolean = false;
		public var sendingEmails:Boolean = false;
		public var onClose:Function;
		
	}
}