package com.enilsson.elephanttrakker.vo
{
	import com.enilsson.utils.eNilssonUtils;
	
	[Bindable]
	public class AppOptionsVO
	{
		public function AppOptionsVO( data:Object = null )
		{
			if ( !data ) return;
			
			for each ( var item:Object in data )
			{
				if ( item.option_name == 'workspace_agreement' )
					workspace_agreement = new XML( item.option_value )
				else
					this[item.option_name] = item.option_value;
			}				
		}
		
		public var agents_agreement:String;
		public var privacy_statement:String;
		public var legalese:String;
		public var paid_for:String;
		public var rss_feed:String;
		public var success_cc:String;
		public var success_check:String;
		public var downline_request:String;
		public var contacts_request:String;
		public var workspace_agreement:XML;

	}
}