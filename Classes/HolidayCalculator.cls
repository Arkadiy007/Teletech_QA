/**********************************************************************
Name: HolidayCalculator
Copyright ¬© notice: Nissan Motor Company
======================================================
Purpose:
Utility class for calculate holidays

======================================================
History:

VERSION AUTHOR DATE DETAIL
1.0 - Yuli Fintescu 11/16/2011 Created
***********************************************************************/
public with sharing class HolidayCalculator {
	//instance variable
	private Set<Date> AllHolidaysOfLastCurrentAndNextYear;
	
	//constructor
	public HolidayCalculator(Date currentDate) {
		AllHolidaysOfLastCurrentAndNextYear = AllHolidaysOfLastCurrentAndNextYearOfDay(currentDate);
	}
	
	//instance method -------------------------------------------
	/**
		return if currentDate is a day-off
	*/
	public Boolean isDayOff(DateTime currentDate) {
		return isDayOff(currentDate, AllHolidaysOfLastCurrentAndNextYear);
	}
	
	/**
		if currentDate is workday, returns currentDate
			else returns the very next workday
	*/
	public DateTime nextWorkDay(DateTime currentDate) {
		return nextWorkDay(currentDate, AllHolidaysOfLastCurrentAndNextYear);
	}
	
	//static methods -------------------------------------------
	/**
		returns all hodiays for the last, currenty and next years
	*/
	public static Set<Date> AllHolidaysOfLastCurrentAndNextYearOfDay(Date currentDate) {
		//get 3 nearby years
		Integer ThisYear = currentDate.year();
		Date LastYear = Date.newInstance(ThisYear - 1, 1, 1), NextYear = Date.newInstance(ThisYear + 1, 12, 31); 
		Date[] Years = new Date[] {LastYear, currentDate, NextYear}; 
		
		//get all company holidays
		List<Holiday> holidays = [Select h.StartTimeInMinutes, 
									h.RecurrenceType, 
									h.RecurrenceStartDate, 
									h.RecurrenceMonthOfYear, 
									h.RecurrenceInterval, 
									h.RecurrenceInstance, 
									h.RecurrenceEndDateOnly, 
									h.RecurrenceDayOfWeekMask, 
									h.RecurrenceDayOfMonth, 
									h.Name, 
									h.IsRecurrence, 
									h.IsAllDay, 
									h.EndTimeInMinutes, 
									h.Description, 
									h.ActivityDate 
								From Holiday h];
		
		Set<Date> holidayDates = new Set<Date>();
		for (Holiday h : holidays)
			Calculate3YearOfHolidayDates(h, holidayDates, Years);
		
		return holidayDates;
	}
	
	/**
	if currentDate is workday, returns currentDate
		else returns the very next workday
	*/
	public static DateTime nextWorkDay(DateTime currentDate, Set<Date> holidayDates) {
		DateTime targetDate = currentDate;
		while (isDayOff(targetDate, holidayDates))
			targetDate = targetDate.addDays(1);
		return targetDate;
	}
	
	/**
		return if currentDate is a day-off
	*/
	public static Boolean isDayOff(DateTime targetDateTime, Set<Date> holidayDates) {
		Date targetDate = targetDateTime.date();
		if (isWeekend(targetDate))
			return true;
		
		return holidayDates.contains(targetDate);
	}
	
	/**
		return if currentDate is a weekend
	*/
	public static Boolean isWeekend(Date currentDate) {
		Integer dow = DayOfWeek(currentDate);
		if (dow == 6 || dow == 0)
			return true;
		return false;
	}
	
	/**
		return the day of week
		March 23, 2009: Year = 2009, Month = 3, day 23. returns day of week: 0 = sunday, 1 = monday ...
	*/
	public static Integer DayOfWeek(Date currentDate) {
		return DayOfWeek(currentDate.year(), currentDate.month(), currentDate.day());
	}
	
	/**
		calculate all hodiays for the last, currenty and next years
	*/
	private static void Calculate3YearOfHolidayDates(Holiday holiday, Set<Date> holidayDates, Date[] Years) {
		if (holiday.IsRecurrence == false && holiday.ActivityDate >= Years[0] && holiday.ActivityDate <= Years[2]) {
			if (!holidayDates.contains(holiday.ActivityDate))
				holidayDates.add(holiday.ActivityDate);
			return;
		}
		
		if (holiday.IsRecurrence == false) 
			return;
		
		//for each year: last, current and next...
		for (Date y : Years) {
			Integer nYear = y.year();
			
			//skip if Recurrence starts after nYear
			if (holiday.RecurrenceStartDate.year() > nYear)
				continue;
			
			Date tHolidayDate = null;
			//Recurs Yearly type
			//----------------------------------------------
			if (holiday.RecurrenceType == 'RecursYearly')
				tHolidayDate = Date.newInstance(nYear, holiday.RecurrenceStartDate.month(), holiday.RecurrenceStartDate.day());
			
			//Recurs Yearly at Nth day
			//----------------------------------------------
			else if (holiday.RecurrenceType == 'RecursYearlyNth') {
				tHolidayDate = getDateByRecurrenceInfo(nYear, holiday.RecurrenceStartDate.month(), 
														DayOfWeekFromMask(holiday.RecurrenceDayOfWeekMask), 
														literalWeekToNumber(holiday.RecurrenceInstance));
			}
			
			//valid if the holiday has not passed the RecurrenceEndDateOnly
			if (tHolidayDate != null && (holiday.RecurrenceEndDateOnly == null || holiday.RecurrenceEndDateOnly >= tHolidayDate)) {
				if (!holidayDates.contains(tHolidayDate))
					holidayDates.add(tHolidayDate);
			}
		}
	}
	
	//It seems that RecurrenceDayOfWeekMask is 2 to DayOfWeek's power. RecurrenceDayOfWeekMask: Saturday=64, Sunday=1
	//return dayOfWeek: Saturday = 6, Sunday = 0
	private static Integer DayOfWeekFromMask(Integer RecurrenceDayOfWeekMask) {
		Integer dayOfWeek = 0;
		Integer result = RecurrenceDayOfWeekMask;
		while (result > 1) {
			result = result >> 1;
			dayOfWeek++;
		}
		
		return dayOfWeek;
	}
	
	
	//March 23, 2009: Year = 2009, Month = 3, day 23. returns day of week: 0 = sunday, 1 = monday ...
	private static Integer DayOfWeek(Integer year, Integer month, Integer day) {
		Integer a = (14 - month) / 12;
		Integer y = year - a;
		Integer m = month + 12*a - 2;
		//Integer d = math.mod((5 + day + y + y/4 + (31*m)/12),  7); 0 = monday, 6 = sunday ...
		Integer d = math.mod((day + y + y/4 - y/100 + y/400 + (31*m)/12), 7);
		return d;
	}
	
	private static Integer literalWeekToNumber(String literal) {
		if (literal == 'First') 
			return 1;
		if (literal == 'Second') 
			return 2;
		if (literal == 'Third') 
			return 3;
		if (literal == 'Fourth') 
			return 4;
			
		return 0;
	}
	
	//RecurrenceDayOfWeek (0=Sunday, 1=Monday, etc.), RecurrenceMonth (Jan=1) and the desired year nYear, RecurrenceInstance nth week
	private static Date getDateByRecurrenceInfo(Integer nYear, Integer RecurrenceMonth, Integer RecurrenceDayOfWeek, Integer RecurrenceInstance) {
		integer nTargetday = RecurrenceDayOfWeek;
		integer nMonth = RecurrenceMonth;
		
		//the earliest possible date in the month on which the holiday could occur
		//where nTh is the number of the occurence of the target day, i.e. given "the third Friday", nTh=3; given "the first Monday" nTh=1
		//To follow the rule "last Monday in May" we calculate the fourth Monday as shown above and then add one week if there are five Mondays in May.
		Integer instance = RecurrenceInstance;
		Integer nTh = instance;
		if (instance == 0)
			nTh = 4;
		integer nEarliestDate = 1 + 7 * (nTh - 1);
		
		//the weekday of the earliest possible date in the month on which the holiday could occur in the given year
		Integer nWeekday = DayOfWeek(nYear, nMonth, nEarliestDate), nOffset = 0;
		
		//the offset between the target weekday and weekday of the earliest possible date in the given year:
		if( nTargetday == nWeekday ) 
			nOffset = 0;
		else {
		  	if( nTargetday < nWeekday ) 
		  		nOffset = nTargetday + (7 - nWeekday);
		  	else 
		  		nOffset = (nTargetday + (7 - nWeekday)) - 7;
		}
		
		//the actual date of the holiday using the earliest possible date and the offset for the given year:
		Date tHolidayDate  = Date.newInstance(nYear, nMonth, nEarliestDate + nOffset);
		if (instance == 0) {
			Date tHolidayDatePlus7 = tHolidayDate.addDays(7);
			if (tHolidayDatePlus7.month() == tHolidayDate.month())
				tHolidayDate = tHolidayDatePlus7;
		}
		
		return tHolidayDate;	
	}
	
	static testMethod void TestHolidayCalculator() {
        List<Holiday> holidays = new List<Holiday>();
		holidays.add(new Holiday(Name='H1',ISALLDAY=true,ACTIVITYDATE=Date.newInstance(2008,12,24),		ISRECURRENCE=false));
		holidays.add(new Holiday(Name='H2',ISALLDAY=true,ACTIVITYDATE=Date.newInstance(2011, 1, 3),		ISRECURRENCE=false));
		holidays.add(new Holiday(Name='H3',ISALLDAY=true,ACTIVITYDATE=Date.newInstance(2011, 5, 4),		ISRECURRENCE=true,RECURRENCESTARTDATE=Date.newInstance(2009, 5, 30),RECURRENCETYPE='RecursYearlyNth',RECURRENCEDAYOFWEEKMASK=2,RECURRENCEINSTANCE='Last',RECURRENCEMONTHOFYEAR='May'));
		holidays.add(new Holiday(Name='H4',ISALLDAY=true,ACTIVITYDATE=Date.newInstance(2011, 5, 4),		ISRECURRENCE=true,RECURRENCESTARTDATE=Date.newInstance(2010, 7, 4),	RECURRENCETYPE='RecursYearly',RECURRENCEDAYOFMONTH=4,RECURRENCEMONTHOFYEAR='July'));
		holidays.add(new Holiday(Name='H5',ISALLDAY=true,ACTIVITYDATE=Date.newInstance(2011, 5, 4),		ISRECURRENCE=true,RECURRENCESTARTDATE=Date.newInstance(2013, 9, 5),	RECURRENCETYPE='RecursYearlyNth',RECURRENCEDAYOFWEEKMASK=2,RECURRENCEINSTANCE='First',RECURRENCEMONTHOFYEAR='September'));
		holidays.add(new Holiday(Name='H6',ISALLDAY=true,ACTIVITYDATE=Date.newInstance(2011, 12, 26),	ISRECURRENCE=false));
		
		holidays.add(new Holiday(Name='H5',ISALLDAY=true,ACTIVITYDATE=Date.newInstance(2011, 5, 4),		ISRECURRENCE=true,RECURRENCESTARTDATE=Date.newInstance(2009, 9, 5),	RECURRENCETYPE='RecursYearlyNth',RECURRENCEDAYOFWEEKMASK=2,RECURRENCEINSTANCE='First',RECURRENCEMONTHOFYEAR='October'));
		holidays.add(new Holiday(Name='H7',ISALLDAY=true,ACTIVITYDATE=Date.newInstance(2011, 5, 4),		ISRECURRENCE=true,RECURRENCESTARTDATE=Date.newInstance(2012, 1, 16),RECURRENCETYPE='RecursYearlyNth',RECURRENCEDAYOFWEEKMASK=2,RECURRENCEINSTANCE='Third',RECURRENCEMONTHOFYEAR='January'));
		holidays.add(new Holiday(Name='H8',ISALLDAY=true,ACTIVITYDATE=Date.newInstance(2011, 5, 4),		ISRECURRENCE=true,RECURRENCESTARTDATE=Date.newInstance(2009, 11, 25),RECURRENCETYPE='RecursYearlyNth',RECURRENCEDAYOFWEEKMASK=32,RECURRENCEINSTANCE='Fourth',RECURRENCEMONTHOFYEAR='November'));
		holidays.add(new Holiday(Name='H9',ISALLDAY=true,ACTIVITYDATE=Date.newInstance(2011, 5, 4),		ISRECURRENCE=true,RECURRENCESTARTDATE=Date.newInstance(2010, 2, 8),	RECURRENCETYPE='RecursYearlyNth',RECURRENCEDAYOFWEEKMASK=4,RECURRENCEINSTANCE='Second',RECURRENCEMONTHOFYEAR='February'));
		
		insert holidays;
		test.startTest();
		Date currentDate = Date.newInstance(2011, 9, 27);
		Date oldChristmas = Date.newInstance(2008, 12, 24);
		
		Set<Date> holidayDates = HolidayCalculator.AllHolidaysOfLastCurrentAndNextYearOfDay(currentDate);
		List<Date> dates = new List<Date>(holidayDates);
		for (Date d : dates) {
			System.assert(!d.isSameDay(oldChristmas));
			System.Debug('***' + d);
		}
		
		//not day off
		currentDate = Date.newInstance(2011, 6, 15);
		System.assert(HolidayCalculator.isDayOff(currentDate, holidayDates) == false);
		
		//weekend
		currentDate = Date.newInstance(2011, 4, 10);
		System.assert(HolidayCalculator.isDayOff(currentDate, holidayDates) == true);
		
		//holiday, test instance methods
		currentDate = Date.newInstance(2011, 7, 4);
		HolidayCalculator calculator = new HolidayCalculator(currentDate);
		System.assert(calculator.isDayOff(currentDate) == true);
		System.Debug(calculator.nextWorkDay(currentDate));
		
		test.stopTest();
	}
}