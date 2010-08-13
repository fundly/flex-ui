package com.enilsson.common.model
{
	import com.enilsson.elephantadmin.models.Icons;
	
	[Bindable]
	public class ContributionType
	{
		public static const CONTRIB_TYPE_TANSACTION : ContributionType = new ContributionType({value:'transaction', label:'Credit Card', icon:Icons.CREDIT_CARD});
		public static const CONTRIB_TYPE_CHECK		: ContributionType = new ContributionType({value:'check', label:'Check', icon:Icons.CHECK});
		public static const CONTRIB_TYPE_PAYPAL		: ContributionType = new ContributionType({value:'paypal', label:'PayPal', icon:Icons.PAY_PAL});		
		public static const CONTRIB_TYPE_IN_KIND	: ContributionType = new ContributionType({value:'inkind', label:'In-kind', icon:Icons.IN_KIND});
		public static const CONTRIB_TYPE_CASH		: ContributionType = new ContributionType({value:'cash', label:'Cash', icon:Icons.CASH});
		public static const CONTRIB_TYPE_NONE		: ContributionType = new ContributionType({value:'none', label:'None', icon:null});
		
		public static const VALUES : Array = [ 
			CONTRIB_TYPE_TANSACTION, 
			CONTRIB_TYPE_CHECK, 
			CONTRIB_TYPE_PAYPAL, 
			CONTRIB_TYPE_IN_KIND, 
			CONTRIB_TYPE_CASH,
			CONTRIB_TYPE_NONE 
		];
		
		public var type : String;
		public var label : String; 
		public var icon : Class;
				
		public function ContributionType( type : Object )
		{
			this.type 	= type.value;
			this.label	= type.label;
			this.icon	= type.icon; 
		}
		
		public static function typeByString( value : String ) : ContributionType {
			for each( var c : ContributionType in VALUES ) {
				if( c.type as String == value ) {
					return c;
				}
			}
			
			return null;
		}
	}
}