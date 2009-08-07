package com.enilsson.elephanttrakker.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	import com.enilsson.elephanttrakker.models.ETModelLocator;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	
	import org.osflash.thunderbolt.Logger;
	
	public class OverviewDelegate
	{
		private var responder:IResponder;
		private var service:Object;
		
		private var _model:ETModelLocator = ETModelLocator.getInstance();
		
		public function OverviewDelegate(responder:IResponder)
		{
			this.responder = responder;
		}
		
		public function getAnnouncements():void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorSelect');

			var whereArray:Object = new Object();
			whereArray['statement'] = '(1)';
			whereArray[1] = { 'what' : 'news.publish', 'val' : 1, 'op' : '=' };
			
			var token:AsyncToken = service.record_tree('news<title:publish_date:publish:description>',whereArray,'news.publish_date DESC');
			token.addResponder(responder);
		}
		
		public function getFundraisingData():void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorSelect');

			var where:Object = new Object();
			where['statement'] = '(1)';
			where[1] = { 'what' : 'statistics.created_by_id', 'val' : _model.session.user_id, 'op' : '=' };

			var token:AsyncToken = service.record_tree(
				'statistics<c:contrib_total:p:pledge_total:month:year>',
				where,
				'statistics.year ASC statistics.month ASC'
			);
			token.addResponder(responder);
		}
		
		public function updateGoalLine(newGoalLine:int):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorEdit');
			
			var params:Object = { 'user_id' : _model.session.user_id, '_fundraising_goal' : newGoalLine };

			Logger.info('Update Goal Line', params);
			
			var token:AsyncToken = service.upsert('tr_users', params);
			token.addResponder(responder);
		}
		
	}
}