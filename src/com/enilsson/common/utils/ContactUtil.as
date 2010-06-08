package com.enilsson.common.utils
{
	import mx.utils.StringUtil;
	
	public class ContactUtil
	{
		public static function hasAddressInfo( contact : Object ) : Boolean {
			
			return( contact != null
				 && isPropertySet(contact, 'address1')
				 && isPropertySet(contact, 'state')
				 && isPropertySet(contact, 'city')
				 && isPropertySet(contact, 'zip') ); 
		}
		
		private static function isPropertySet( contact : Object, prop : String ) : Boolean {
			return ( contact != null && 
				contact[prop] !== undefined && 
				contact[prop] != null && 
				StringUtil.trim( contact[prop] ).length > 0 );
		}
	}
}