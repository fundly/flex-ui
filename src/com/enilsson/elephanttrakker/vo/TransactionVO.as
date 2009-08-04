package com.enilsson.elephanttrakker.vo
{
	import com.adobe.cairngorm.vo.IValueObject;
	
	[RemoteClass(alias="com.enilsson.elephanttrakker.vo.TransactionVO")]
	public class TransactionVO implements IValueObject
	{
		public var card_type:String;
		public var card_number:String;
		public var exp_date_MM:String;
		public var exp_date_YYYY:String;
		public var ccv2:String;
		public var amount:String;
		public var full_name:String;
		public var fname:String;
		public var lname:String;
		public var address:String;
		public var address2:String;
		public var city:String;
		public var state:String;
		public var zip:String;

		public function set data( data:Object ):void
		{
			if ( data.hasOwnProperty( 'card_number_type' ) ) this.card_type = data.card_number_type;
			if ( data.hasOwnProperty( 'card_number' ) ) this.card_number = data.card_number;
			if ( data.hasOwnProperty( 'expiration_month' ) ) this.exp_date_MM = data.expiration_month;
			if ( data.hasOwnProperty( 'expiration_year' ) ) this.exp_date_YYYY = data.expiration_year;
			if ( data.hasOwnProperty( 'ccv2' ) ) this.ccv2 = data.ccv2;
			if ( data.hasOwnProperty( 'amount' ) ) this.amount = data.amount;
			if ( data.hasOwnProperty( 'full_name' ) ) this.full_name = data.full_name;
			if ( data.hasOwnProperty( 'fname' ) ) this.fname = data.fname;
			if ( data.hasOwnProperty( 'lname' ) ) this.lname = data.lname;
			if ( data.hasOwnProperty( 'address' ) ) this.address = data.address;
			if ( data.hasOwnProperty( 'address1' ) ) this.address = data.address1;
			if ( data.hasOwnProperty( 'address2' ) ) this.address2 = data.address2;
			if ( data.hasOwnProperty( 'city' ) ) this.city = data.city;
			if ( data.hasOwnProperty( 'state' ) ) this.state = data.state;
			if ( data.hasOwnProperty( 'zip' ) ) this.zip = data.zip;
			
			if ( data.hasOwnProperty( 'expiration' ) )
			{
				var exp:Array = String(data.expiration).split("/");
				
				if ( exp.length == 2 )
				{
					this.exp_date_MM = exp[0];
					this.exp_date_YYYY = exp[1];
				}
				else
				{
					this.exp_date_MM = '';
					this.exp_date_YYYY = '';
				}
			}
		}	
		
/* 		public function get data ():Object
		{
			var obj:Object = {
				card_type : card_type,
				card_number : card_number,
				exp_date_MM : exp_date_MM,
				exp_date_YYYY : exp_date_YYYY,
				ccv2 : ccv2,
				amount : amount,
				full_name : full_name,
				fname : fname,
				lname : lname,
				address : address,
				address2 : address2,
				city : city,
				state : state,
				zip : zip
			}
			
			return obj;
		}	 */

	}
}