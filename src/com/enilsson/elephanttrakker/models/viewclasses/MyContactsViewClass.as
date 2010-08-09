package com.enilsson.elephanttrakker.models.viewclasses
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.enilsson.vo.ErrorVO;
	
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class MyContactsViewClass
	{
		public function MyContactsViewClass()
		{
		}
		
		public var contacts:ArrayCollection = new ArrayCollection();
		public var showTable:Boolean = false;
		public var numContacts:int = -1;
		public var showPagination:Boolean = false;
		
		public var contactsLayout:Object;
		public var contactData:Object = new Object();
		public var contactInfo:Object = new Object();
		public var test:Object = new Object();
		public var showContactForm:Boolean = false;
		
		public var currSelectedItem:int = -1;
		
		public var currCreatedID:int;
		
		public var contactPledges:ArrayCollection;
		public var contactTransactions:ArrayCollection;		
		public var contactSavedCalls:ArrayCollection;		
		
		public var showContactsTools:Boolean = false;
		
		public var contactElementsViewState:uint = 0;
		public var textonly:Boolean = false;
		
		public var errorVO:ErrorVO;
		
		public var isSubmitting:Boolean = false;

		public var onClose:Function;
		
		public var pledgeStack:uint = 0;
		
		public var lastQuery:CairngormEvent;
		
		public var popupContactForm:Boolean = false;

		public var isShared:Boolean = false;
		public var sharedName:String = "";
		
		public function resetPopupContactForm():void
		{
			popupContactForm = true;
		}
		
		/*-- Contact Uploader variables --*/
		public var popupIcon:Class;
		public var popupTitle:String = 'My Contacts Tools';
		public var stackIndex:int = 0;
		
		public var importData:ArrayCollection = new ArrayCollection();
		public var importTotal:int;
		public var importFields:Array = [];
		public var importIgnore:Array = [];
		public var columnHeaderCombos:Array;
		public var firstRow:Object;
		public var headerFirst:Boolean = false;
		public var importMessage:String;	
		public var importCurrPage:int = 0;	
	}
}