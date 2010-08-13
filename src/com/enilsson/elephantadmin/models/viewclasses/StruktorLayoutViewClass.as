package com.enilsson.elephantadmin.models.viewclasses
{
	import com.enilsson.elephantadmin.vo.StruktorLayoutVO;
	
	
	/**
	 * Storage point for all the layout structures
	 */
	[Bindable]
	public class StruktorLayoutViewClass
	{
		public var loaded:Boolean = false;

		public var checks:StruktorLayoutVO;
		public var contacts:StruktorLayoutVO;
		public var contributions_misc:StruktorLayoutVO;
		public var email_attachments:StruktorLayoutVO;
		public var email_log:StruktorLayoutVO;
		public var email_system_templates:StruktorLayoutVO;
		public var email_user_templates:StruktorLayoutVO;
		public var events:StruktorLayoutVO;
		public var news:StruktorLayoutVO;
		
		public function set pledges( val : StruktorLayoutVO ) : void {
			// explicitly remove pledge_amount validation from the admin UI
			if(val != null) {
				for each( var o : Object in val.fields ) {
					if( o.fieldname == 'pledge_amount' ) {
						o.rules = String( o.rules ).replace('selection_numeric', '');
						break;
					}
				}
			}			
			_pledges = val;
		}
		public function get pledges() : StruktorLayoutVO {
			return _pledges;
		}
		private var _pledges : StruktorLayoutVO;
		
		public var reporting:StruktorLayoutVO;
		public var resources:StruktorLayoutVO;		
		public var tr_users:StruktorLayoutVO;
		public var transactions:StruktorLayoutVO;
		public var transactions_failed:StruktorLayoutVO;
		
		
	}
}