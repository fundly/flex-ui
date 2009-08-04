package com.enilsson.elephantadmin.models.viewclasses
{
	import com.enilsson.elephantadmin.models.Icons;
	
	import mx.collections.ArrayCollection;

	public class RecordViewClass
	{
		[Bindable] public var sid:String = '';
		
		[Bindable] public var tree:Object;
		[Bindable] public var layout:Object;		
		[Bindable] public var icon:Class;
		[Bindable] public var auditHistory:ArrayCollection;
		
		[Bindable] public var recordViewState:Number = 0;
		
		[Bindable] public var deletedID:Number = 0;
		[Bindable] public var deletedData:Object;
		
		[Bindable] public var tableIcons:Object;		
		
		public function RecordViewClass()
		{
			tableIcons = {
				'checks' : Icons.CHECK,
				'contacts' : Icons.CONTACTS,
				'email_attachments' : Icons.EMAIL,
				'email_log' : Icons.EMAIL,
				'email_system_templates' : Icons.EMAIL,
				'email_user_templates' : Icons.EMAIL,
				'events' : Icons.EVENTS,
				'pledges' : Icons.PLEDGE,
				'reporting' : Icons.REMINDERS,
				'resources' : Icons.RESOURCES,		
				'tr_users' : Icons.USER,
				'transactions' : Icons.CREDIT_CARD,
				'transactions_failed' : Icons.CREDIT_CARD				
			}
		}
	}
}