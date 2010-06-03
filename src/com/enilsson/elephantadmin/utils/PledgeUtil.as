package com.enilsson.elephantadmin.utils
{
	/**
	 * Utility class for Pledges
	 */
	public final class PledgeUtil
	{
		/**
		 * Checks whether all of a pledge's contributions have been refunded.
		 * 
		 * @param pledge	A pledge object.
		 * @return 			A Boolean value indicating if all contributions have been refunded.
		 */
		public static function allContribsRefunded( pledge : Object ) : Boolean {
			
			var p : Object = pledge;
			
			return  ( isPledge(p) && p.pledge_amount == 0 );
		}
		
		public static function isPledge( o : Object ) : Boolean {
			return  ( o!= null && o.hasOwnProperty("pledge_amount") );
		}
	}
}