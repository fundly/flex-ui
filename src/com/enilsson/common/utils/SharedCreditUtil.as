package com.enilsson.common.utils
{
	public class SharedCreditUtil
	{
		public static function isSharedCreditCheck( value : Object ) : Boolean {
			return ( value && value.hasOwnProperty('checks_refid') && value['checks_refid'] != null );
		}
		
		public static function isSharedCreditTransaction( value : Object ) : Boolean {
			return ( value && value.hasOwnProperty('transactions_refid') && value['transactions_refid'] != null );
		}
		
		public static function isSharedCreditPledge( value :  Object ) : Boolean {
			return ( value && value.hasOwnProperty('pledges_refid') && value['pledges_refid'] != null );
		}
	}
}