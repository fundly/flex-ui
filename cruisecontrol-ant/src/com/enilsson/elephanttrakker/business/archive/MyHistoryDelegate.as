package com.enilsson.elephanttrakker.business
{
	import com.adobe.cairngorm.business.ServiceLocator;
	import com.enilsson.elephanttrakker.models.ETModelLocator;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	
	import org.osflash.thunderbolt.Logger;
	
	public class MyHistoryDelegate
	{
		private var responder:IResponder;
		private var service:Object;
		
		private var _model:ETModelLocator = ETModelLocator.getInstance();
		
		public function MyHistoryDelegate(responder:IResponder)
		{
			this.responder = responder;
		}
		
		public function getPledges( iFrom:int, iCount:int, paginate:String, sort:String, where:Object ):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorSelect');
			
			sort = sort == '' ? 'pledges.pledge_date DESC' : sort;

			var whereObj:Object = {'statement':'(1)','1':{ 
				'what' : 'pledges.created_by_id',
				'val' : _model.session.user_id,
				'op' : '='
			}};
			
			if(where == null) where = whereObj;
			
			var token:AsyncToken = service.record_tree('pledges(event_id<source_code>)', where, sort, iFrom, iCount, paginate);			
			token.addResponder(responder);
		}
		
		public function getContribs( iFrom:int, iCount:int, paginate:String, sort:String ):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorSelect');
			
			sort = sort == '' ? 'transactions.created_on DESC' : sort;

			var where:Object = {'statement':'(1)','1':{ 
				'what' : 'transactions.created_by_id',
				'val' : _model.session.user_id,
				'op' : '='
			}};
		
			var token:AsyncToken = service.record_tree('transactions', where, sort, iFrom, iCount, paginate);			
			token.addResponder(responder);
		}		
		
		
		public function getCheckContribs( iFrom:int, iCount:int, paginate:String, sort:String ):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorSelect');
			
			sort = sort == '' ? 'checks.created_on DESC' : sort;

			var where:Object = {'statement':'(1)','1':{ 
				'what' : 'checks.created_by_id',
				'val' : _model.session.user_id,
				'op' : '='
			}};
			
			var token:AsyncToken = service.record_tree('checks', where, sort, iFrom, iCount, paginate);			
			token.addResponder(responder);
		}		
		
		public function search( table:String, searchTerm:String, iFrom:int, iCount:int ):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorSearch');
			
			var token:AsyncToken = service.table(table, searchTerm, null, iFrom, iCount);
			token.addResponder(responder);
		}
		
		
		public function getStatisticsData():void
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
			
			//var token:AsyncToken = service.record_tree('statistics',null,'statistics.year ASC statistics.month ASC');
			//token.addResponder(responder);
		}

		public function getDownlineData():void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorSelect');
			
			var token:AsyncToken = service.record_tree('downline_stats',_model.session.user_id);
			token.addResponder(responder);
		}
		
		public function getChartData():void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorCounting');
			
			var token:AsyncToken = service.global_count('pledges','state','pledge_amount');
			token.addResponder(responder);
		}
				
		public function getContributions(obj:Object):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorSelect');
			
			obj.sort = obj.sort == '' ? 'transactions.created_on DESC' : obj.sort;
			
			var token:AsyncToken = service.record_tree('transactions', null, obj.sort, obj.iFrom, obj.iCount, obj.paginate);			
			token.addResponder(responder);
		}
		
		
		public function getSavedCalls( iFrom:int, iCount:int, paginate:String, sort:String ):void
		{
			this.service = ServiceLocator.getInstance().getRemoteObject('struktorSelect');
			
			sort = sort == '' ? 'user_storage.created_on DESC' : sort;
			var where:Object = {'statement':
											'(1 AND 2)',
											'1':{ 
											'what' : 'user_storage.table',
											'val' : 'pledges',
											'op' : '='
											},
											'2':{ 
												'what' : 'user_storage.created_by_id',
												'val' : _model.session.user_id,
												'op' : '='
											}
								};
			
			
			var token:AsyncToken = service.record_tree('user_storage',where, sort, iFrom, iCount, paginate);
			token.addResponder(responder);
		}

	}
}