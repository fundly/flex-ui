package com.enilsson.elephanttrakker.modules.business
{
	import com.enilsson.elephanttrakker.modules.progressreports.business.*;
	
	public dynamic class DelegateMap extends Array
	{
		
		public static const PROGRESS_REPORT			: int = 0;
		public static const DOWNLINE				: int = 1;
		
		public function DelegateMap()
		{
			super();
			
			this[PROGRESS_REPORT] 		= ProgressReportsDelegate;
			this[DOWNLINE]				= DownlineDelegate;
		}

	}
}