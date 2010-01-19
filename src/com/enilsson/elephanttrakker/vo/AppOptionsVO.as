package com.enilsson.elephanttrakker.vo
{
	[Bindable]
	public class AppOptionsVO
	{
		public function AppOptionsVO( data:Object = null )
		{
			if ( !data ) return;
			
			for each ( var item:Object in data )
			{
				switch( item.option_name ) {
					
					case 'workspace_agreement':
					case 'modules_config':
						this[item.option_name] = new XML( item.option_value )
					break;
					default:
						this[item.option_name] = item.option_value;
					break;
				}
			}
		}
		
		public var agents_agreement:String;
		public var privacy_statement:String;
		public var legalese:String;
		public var paid_for:String;
		public var rss_feed:String;
		public var success_cc:String;
		public var success_check:String;
		public var success_none:String;
		public var downline_request:String;
		public var contacts_request:String;
		public var workspace_agreement:XML;
		public var modules_config:XML;
	}
}