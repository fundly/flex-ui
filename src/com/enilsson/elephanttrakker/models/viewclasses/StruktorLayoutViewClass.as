package com.enilsson.elephanttrakker.models.viewclasses
{
	import com.enilsson.elephanttrakker.vo.StruktorLayoutVO;
	
	
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

		public var checks:StruktorLayoutVO;
		public var contacts:Object;
		public var email_attachments:Object;
		public var email_log:Object;
		public var email_system_templates:Object;
		public var email_user_templates:Object;
		public var events:Object;
		public var pledges:StruktorLayoutVO;
		public var reporting:Object;
		public var resources:Object;		
		public var tr_users:Object;
		public var transactions:StruktorLayoutVO;
		public var transactions_failed:Object;
	}
}