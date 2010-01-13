package com.enilsson.elephanttrakker.modules.progressreports.events
{
	import mx.utils.UIDUtil;
	
	public final class Events
	{
		public static const GET_TOP_FUNDRAISERS						: String = createId( 'getTopFundraisers' );
		public static const GET_TOP_FUNDRAISERS_DOWNLINE_CONTRIBS	: String = createId( 'getTopFundraisersDownlineContribs' );
		public static const GET_TOP_FUNDRAISERS_DOWNLINE_USERS		: String = createId( 'getTopFundraisersDownlineUsers' );
		
		public static const GET_GROUP_STATS							: String = createId( 'getGroupStats' );
		
		private static function createId( val : String ) : String {
			return val + "_" + UIDUtil.createUID(); 	
		}
	}
}