package com.enilsson.elephantadmin.views.modules.pledge_workspace.model
{
	public class ContributionType
	{
		public static const CONTRIB_TYPE_TANSACTION : ContributionType = new ContributionType({value:'transaction', label:'Credit Card'});
		public static const CONTRIB_TYPE_CHECK		: ContributionType = new ContributionType({value:'check', label:'Check'});
		public static const CONTRIB_TYPE_PAYPAL		: ContributionType = new ContributionType({value:'paypal', label:'PayPal'});		
		public static const CONTRIB_TYPE_IN_KIND	: ContributionType = new ContributionType({value:'inkind', label:'In-kind'});
		public static const CONTRIB_TYPE_CASH		: ContributionType = new ContributionType({value:'cash', label:'Cash'});
		
		public var type : String;
		public var label : String; 
				
		public function ContributionType( type : Object )
		{
			this.type  = type.value;
			this.label = type.label;
		}

	}
}