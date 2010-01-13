package com.enilsson.elephanttrakker.modules.progressreports.business
{
	public class DelegateFactory
	{
		public static const PROGRESS_REPORT			: int = 0;
		public static const PROGRESS_REPORT_MOCK	: int = 1;
		
		public static function create( type:int, services : Services ) : IProgressReportsDelegate {
			
			var d : IProgressReportsDelegate;
			
			switch( type ) {
				case PROGRESS_REPORT:
					d = new ProgressReportsDelegate( services.progressReportsService );
				break;
				case PROGRESS_REPORT_MOCK:
//					d = new ProgressReportsMockDelegate();
				break;
			}
			
			return d;
		}
	}
}