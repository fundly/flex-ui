package com.enilsson.elephantadmin.views.modules.search.grids
{
	import com.enilsson.utils.EDateUtil;
	
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.formatters.CurrencyFormatter;
	import mx.formatters.DateFormatter;
	
	/**
	 * A Class containing common labelFunctions for the search datagrids.
	 **/	
	public final class LabelFunctionCollection
	{
		public static function getFirstName( item : Object, column : DataGridColumn ) : String
		{
			var fname : String = "";
			if(item) 
				fname = item.fname != undefined ? item.fname : item._fname;				
			return fname;
		}
		
		public static function getLastName( item : Object, column : DataGridColumn ) : String
		{
			var lname : String = "";
			if(item)
				lname = item.lname != undefined ? item.lname : item._lname;			
			return lname;
		}
				
		public static function getFullName( item : Object, column : DataGridColumn ) : String
		{
			return getFirstName(item, column) + " " + getLastName(item, column);			
		}
		
		public static function getCity( item : Object, column : DataGridColumn ) : String
		{
			var city : String = "";
			if(item)
				city = item.city != undefined ? item.city : item._city;
			return city;	
		}
		
		public static function getState( item : Object, column : DataGridColumn ) : String
		{
			var state : String = "";
			if(item)
				state = item.state != undefined ? item.state : item._state;
			return state;	
		}
		
		public static function getZip( item : Object, column : DataGridColumn ) : String
		{
			var zip : String = "";
			if(item)
				zip = item.zip != undefined ? item.zip : item._zip;
			return zip;
		}
		
		public static function getAddress1( item : Object, column : DataGridColumn ) : String
		{
			var address1 : String = "";
			if(item)
				address1 = item.address1 != undefined ? item.address1 : item._address1;
			return address1;
		}
				
		public static function getFullAddress( item : Object, column : DataGridColumn ) : String
		{
			return item ? ( getAddress1( item, column ) + ", " + getCityAndState( item, column ) + " " + getZip(item, column) ) : "";
		}
		
		public static function getCityAndState( item: Object, column : DataGridColumn ) : String
		{
			return getCity(item, column) + " " + getState( item, column );
		}
		
		public static function getPledgeAmount( item : Object, column : DataGridColumn ) : String
		{
			var amount : String = "0";
			var cf:CurrencyFormatter = new CurrencyFormatter();
			cf.precision = 2;			
			if(item)
				amount = item.pledge_amount != undefined ? item.pledge_amount : "0";
			
			return "Pledged: " + cf.format(amount);
		}
		
		public static function getPledgeTotal( item : Object, column : DataGridColumn ) : String
		{			
			var total : String = "0";
			var cf:CurrencyFormatter = new CurrencyFormatter();
			cf.precision = 2;			
			if(item)
				total = item.pledge_total != undefined ? item.pledge_total : item._pledge_total;
				
			return "Pledged: " + cf.format(total);
		}
		
		public static function getContribTotal( item : Object, column : DataGridColumn ) : String
		{
			var contrib : String = "0";
			var cf:CurrencyFormatter = new CurrencyFormatter();
			cf.precision = 2;			
			if(item)
				contrib = item.contrib_total != undefined ? item.contrib_total : item._contrib_total;
			
			return "Contrib'd: " + cf.format(contrib);
		}			
		
		public static function getSender( item : Object, column : DataGridColumn ) : String
		{
			return item ? ( item.sender_fname + " " + item.sender_lname + " " + item.sender_fid ) : "";
		}
		
		public static function getVenue( item : Object, column : DataGridColumn ) : String
		{
			return item ? ( item.venue_name + " " + item.venue_address + " " + item.city + " " + item.state + " " + item.zip ) : "";
		}
		
		public static function getEventDate( item : Object, column : DataGridColumn ) : String
		{
			var df:DateFormatter = new DateFormatter();
			df.formatString = 'MM/DD/YYYY';
			
			return df.format( new Date ( item.date_time * 1000 ) );
		}

		public static function getPledgeDate( item : Object, column : DataGridColumn ):String 
		{
			var df:DateFormatter = new DateFormatter();
			df.formatString = "MM/DD/YYYY"
			return df.format( EDateUtil.timestampToLocalDate(item.pledge_date) );
		}

	}
}