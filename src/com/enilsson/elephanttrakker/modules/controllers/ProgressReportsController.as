package com.enilsson.elephanttrakker.modules.controllers
{
	import com.enilsson.common.events.GetEvent;
	import com.enilsson.elephanttrakker.modules.business.IProgressReportsDelegate;
	
	public class ProgressReportsController extends ControllerBase
	{
		public function getGroupStats( event : GetEvent ) : void {
			if( _delegate && event )
				executeGet( event, _delegate.getGroupStats );
		}
		
		public function getTopFundraisers( event : GetEvent ) : void {
			if( _delegate && event )
				executeGet( event, _delegate.getTopFundraisers );
		}
		
		public function getTopFundraisersByDownlineContributions( event : GetEvent ) : void {
			if( _delegate && event )
				executeGet( event, _delegate.getTopFundraisersByDownlineContributions );
		}
		
		public function getTopFundraisersByDownlineUsers( event : GetEvent ) : void {
			if( _delegate && event )
				executeGet( event, _delegate.getTopFundraisersByDownlineUsers );
		}
		
		override public function set delegate(val:Object):void {
			_delegate = val as IProgressReportsDelegate;
		}
		override public function get delegate():Object {
			return _delegate;
		}
		
		private var _delegate : IProgressReportsDelegate;
		
		
	}
}