package com.enilsson.elephanttrakker.modules.compgraphs.events
{
	import mx.utils.UIDUtil;
	
	public final class Events
	{
		public static const GET_FUNDRAISER_STATS	: String = createId( 'getFundraiserStats' );
		public static const GET_GROUP_STATS			: String = createId( 'getGroupStats' );
		
		private static function createId( val : String ) : String {
			return val + "_" + UIDUtil.createUID(); 	
		}
	}
}