package com.enilsson.elephantadmin.models.viewclasses
{
	import com.enilsson.elephantadmin.vo.StruktorLayoutVO;
	
	
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
		public var contacts:StruktorLayoutVO;
		public var email_attachments:StruktorLayoutVO;
		public var email_log:StruktorLayoutVO;
		public var email_system_templates:StruktorLayoutVO;
		public var email_user_templates:StruktorLayoutVO;
		public var events:StruktorLayoutVO;
		public var in_kinds:StruktorLayoutVO;
		public var pledges:StruktorLayoutVO;
		public var news:StruktorLayoutVO;
		public var reporting:StruktorLayoutVO;
		public var resources:StruktorLayoutVO;		
		public var tr_users:StruktorLayoutVO;
		public var transactions:StruktorLayoutVO;
		public var transactions_failed:StruktorLayoutVO;
	}
}