/**********************************************************************
Name: Event_Before
Copyright © notice: Nissan Motor Company.
======================================================
Purpose
Events cannot be added to a closed case.
======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Yuli Fintescu 02/09/2012 Created
***********************************************************************/
trigger Event_Before on Event (before insert) {
    // ********** Tasks cannot be added to a closed case
    if (Trigger.isInsert) {
	    Set<ID> caseIds = new Set<ID>();
		for (Event t: Trigger.new) {
			caseIds.add(t.WhatId);
		}
		
		List<Case> cases = [select Id, IsClosed from Case where Id in :caseIds and RecordType.Name in ('CA', 'CA Closed Case', 'CA Email Infiniti', 'CA Email Nissan', 'CA EXEC', 'DPIC TSO', 'Roadside Assistance', 'T5', 'TECH LINE') and IsClosed = true];
		Map<ID, Case> mapCases = new Map<ID, Case>(cases);
		for (Event t: Trigger.new) {
			if (mapCases.containsKey(t.WhatId))
				t.addError('Events cannot be added to a closed case.');
		}
    }
}