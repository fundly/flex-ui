package com.enilsson.elephanttrakker.models.viewclasses
{
	
	/**
	 * Storage point for all the layout structures
	 */
	[Bindable]
	public class StruktorLayoutViewClass
	{
		public function StruktorLayoutViewClass()
		{
		}
		
		public var loaded:Boolean = false;

		public var checks:Object;
		public var contacts:Object;
		public var email_attachments:Object;
		public var email_log:Object;
		public var email_system_templates:Object;
		public var email_user_templates:Object;
		public var events:Object;
		public var pledges:Object;
		public var reporting:Object;
		public var resources:Object;		
		public var tr_users:Object;
		public var transactions:Object;
		public var transactions_failed:Object;
	}
}