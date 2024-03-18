/*
 * Copyright (c) 2006 Ho Ngoc Duc. All Rights Reserved.
 * Astronomical algorithms from the book "Astronomical Algorithms" by Jean Meeus, 1998
 *
 * Permission to use, copy, modify, and redistribute this software and its
 * documentation for personal, non-commercial use is hereby granted provided that
 * this copyright notice and appropriate documentation appears in all copies.
 */
import 'dart:math';

var PI = pi;

const canList = [
  "Canh",
  "Tân",
  "Nhâm",
  "Quý",
  "Giáp",
  "Ất",
  "Bính",
  "Đinh",
  "Mậu",
  "Kỉ"
];
const chiList = [
  "Thân",
  "Dậu",
  "Tuất",
  "Hợi",
  "Tý",
  "Sửu",
  "Dần",
  "Mẹo",
  "Thìn",
  "Tị",
  "Ngọ",
  "Mùi"
];

const chiForMonthList = [
  "Dần",
  "Mẹo",
  "Thìn",
  "Tị",
  "Ngọ",
  "Mùi",
  "Thân",
  "Dậu",
  "Tuất",
  "Hợi",
  "Tý",
  "Sửu",
];

const CAN = [
  'Giáp',
  'Ất',
  'Bính',
  'Đinh',
  'Mậu',
  'Kỷ',
  'Canh',
  'Tân',
  'Nhâm',
  'Quý'
];
const CHI = [
  'Tý',
  'Sửu',
  'Dần',
  'Mẹo',
  'Thìn',
  'Tỵ',
  'Ngọ',
  'Mùi',
  'Thân',
  'Dậu',
  'Tuất',
  'Hợi'
];
const TIETKHI = [
  'Xuân phân',
  'Thanh minh',
  'Cốc vũ',
  'Lập hạ',
  'Tiểu mãn',
  'Mang chủng',
  'Hạ chí',
  'Tiểu thử',
  'Đại thử',
  'Lập thu',
  'Xử thử',
  'Bạch lộ',
  'Thu phân',
  'Hàn lộ',
  'Sương giáng',
  'Lập đông',
  'Tiểu tuyết',
  'Đại tuyết',
  'Đông chí',
  'Tiểu hàn',
  'Đại hàn',
  'Lập xuân',
  'Vũ thủy',
  'Kinh trập'
];
const GIO_HD = [
  '110100101100',
  '001101001011',
  '110011010010',
  '101100110100',
  '001011001101',
  '010010110011'
];

/* Discard the fractional part of a number, e.g., INT(3.2) = 3 */
INT(double d) {
  return d.toInt();
}

/* Compute the (integral) Julian day number of day dd/mm/yyyy, i.e., the number 
 * of days between 1/1/4713 BC (Julian calendar) and dd/mm/yyyy. 
 * Formula from http://www.tondering.dk/claus/calendar.html
 */
int jdFromDate(int dd, int mm, int yy) {
  var a = (14 - mm) ~/ 12;
  var y = yy + 4800 - a;
  var m = mm + 12 * a - 3;
  var jd = dd + (153 * m + 2) ~/ 5 + 365 * y + y ~/ 4 - y ~/ 100 + y ~/ 400 - 32045;
  if (jd < 2299161) {
    jd = dd + (153 * m + 2) ~/ 5 + 365 * y + y ~/ 4 - 32083;
  }
  return jd;
}

/* Convert a Julian day number to day/month/year. Parameter jd is an integer */
List<int> jdToDate(int jd) {
  var a, b, c, d, e, m;
  if (jd > 2299160) { // After 5/10/1582, Gregorian calendar
    a = jd + 32044;
    b = (4 * a + 3) ~/ 146097;
    c = a - (b * 146097) ~/ 4;
  } else {
    b = 0;
    c = jd + 32082;
  }

  d = (4 * c + 3) ~/ 1461;
  e = c - (1461 * d) ~/ 4;
  m = (5 * e + 2) ~/ 153;
  var day = e - (153 * m + 2) ~/ 5 + 1;
  var month = m + 3 - 12 * (m ~/ 10);
  var year = b * 100 + d - 4800 + (m ~/ 10);

  return [day, month, year];
}

/* Compute the time of the k-th new moon after the new moon of 1/1/1900 13:52 UCT 
 * (measured as the number of days since 1/1/4713 BC noon UCT, e.g., 2451545.125 is 1/1/2000 15:00 UTC).
 * Returns a floating number, e.g., 2415079.9758617813 for k=2 or 2414961.935157746 for k=-2
 * Algorithm from: "Astronomical Algorithms" by Jean Meeus, 1998
 */
double newMoon(int k) {
  var T = k / 1236.85; // Time in Julian centuries from 1900 January 0.5
  var T2 = T * T;
  var T3 = T2 * T;
  var dr = pi / 180; 
  var Jd1 = 2415020.75933 + 29.53058868 * k + 0.0001178 * T2 - 0.000000155 * T3;
  Jd1 += 0.00033 * sin((166.56 + 132.87 * T - 0.009173 * T2) * dr); 

  var M = 359.2242 + 29.10535608 * k - 0.0000333 * T2 - 0.00000347 * T3; 
  var Mpr = 306.0253 + 385.81691806 * k + 0.0107306 * T2 + 0.00001236 * T3; 
  var F = 21.2964 + 390.67050646 * k - 0.0016528 * T2 - 0.00000239 * T3; 

  var C1 = (0.1734 - 0.000393 * T) * sin(M * dr) + 0.0021 * sin(2 * dr * M);
  C1 -= 0.4068 * sin(Mpr * dr) + 0.0161 * sin(dr * 2 * Mpr);
  // ... (Rest of C1 calculation)

  var deltat = (T < -11) 
      ? 0.001 + 0.000839 * T + 0.0002261 * T2 - 0.00000845 * T3 - 0.000000081 * T * T3
      : -0.000278 + 0.000265 * T + 0.000262 * T2;

  var JdNew = Jd1 + C1 - deltat;
  return JdNew;
}

/* Compute the longitude of the sun at any time. 
 * Parameter: floating number jdn, the number of days since 1/1/4713 BC noon
 * Algorithm from: "Astronomical Algorithms" by Jean Meeus, 1998
 */
double sunLongitude(double jdn) {
  var T = (jdn - 2451545.0) / 36525; // Time in Julian centuries 
  var T2 = T * T;
  var dr = pi / 180; // degree to radian

  var M = 357.52910 + 35999.05030 * T - 0.0001559 * T2 - 0.00000048 * T * T2; // mean anomaly

  var L0 = 280.46645 + 36000.76983 * T + 0.0003032 * T2; // mean longitude

  var DL = (1.914600 - 0.004817 * T - 0.000014 * T2) * sin(dr * M);
  DL += (0.019993 - 0.000101 * T) * sin(dr * 2 * M) + 0.000290 * sin(dr * 3 * M); 

  var L = L0 + DL; // true longitude
  L = L * dr; // Convert to radians
  L = L - pi * 2 * (L / (pi * 2)).floor(); // Normalize (0, 2*pi)

  return L;
}

/* Compute sun position at midnight of the day with the given Julian day number. 
 * The time zone if the time difference between local time and UTC: 7.0 for UTC+7:00.
 * The  returns a number between 0 and 11. 
 * From the day after March equinox and the 1st major term after March equinox, 0 is returned. 
 * After that, return 1, 2, 3 ... 
 */
int getSunLongitude(double dayNumber, double timeZone) {
  // Calculate adjusted day number for time zone offset
  var adjustedDayNumber = dayNumber - 0.5 - timeZone / 24;

  // Calculate Sun's longitude (assuming you have the 'sunLongitude' function translated)
  var longitudeRadians = sunLongitude(adjustedDayNumber);  

  // Convert longitude from radians to sixths of a circle and return as integer 
  return (longitudeRadians / pi * 6).floor();  
}

/* Compute the day of the k-th new moon in the given time zone.
 * The time zone if the time difference between local time and UTC: 7.0 for UTC+7:00
 */
int getNewMoonDay(int k, double timeZone) {
  var julianDateOfNewMoon = newMoon(k) + 0.5 + timeZone / 24;
  return julianDateOfNewMoon.floor(); // Or .toInt() if you're certain it'll always be whole
}

/* Find the day that starts the luner month 11 of the given year for the given time zone */
int getLunarMonth11(int yy, double timeZone) {
  var off = jdFromDate(31, 12, yy) - 2415021;
  var k = (off / 29.530588853).floor(); 
  var nm = getNewMoonDay(k, timeZone); 
  var sunLong = getSunLongitude(nm.toDouble(), timeZone); 

  if (sunLong >= 9) {
    nm = getNewMoonDay(k - 1, timeZone);
  }

  return nm;
}

/* Find the index of the leap month after the month starting on the day a11. */
int getLeapMonthOffset(int a11, double timeZone) {
  var k = ((a11 - 2415021.076998695) / 29.530588853 + 0.5).floor();
  var last = 0; 
  var i = 1; 
  var arc = getSunLongitude(getNewMoonDay(k + i, timeZone).toDouble(), timeZone);

  do {
    last = arc;
    i++;
    arc = getSunLongitude(getNewMoonDay(k + i, timeZone).toDouble(), timeZone);
  } while (arc != last && i < 14);

  return i - 1;
}

/* Comvert solar date dd/mm/yyyy to the corresponding lunar date */
List<int> convertSolar2Lunar(int dd, int mm, int yy, double timeZone) {
  var k, dayNumber, monthStart, a11, b11, lunarDay, lunarMonth, lunarYear, lunarLeap;

  // Calculate Julian Day Number
  dayNumber = jdFromDate(dd, mm, yy); 

  // Find New Moon day within the month
  k = ((dayNumber - 2415021.076998695) / 29.530588853).floor();
  monthStart = getNewMoonDay(k + 1, timeZone); 
  if (monthStart > dayNumber) {
    monthStart = getNewMoonDay(k, timeZone);
  }

  // Determine Lunar Year
  a11 = getLunarMonth11(yy, timeZone);
  b11 = a11;
  if (a11 >= monthStart) {
    lunarYear = yy;
    a11 = getLunarMonth11(yy - 1, timeZone);
  } else {
    lunarYear = yy + 1;
    b11 = getLunarMonth11(yy + 1, timeZone);
  }

  // Calculate Lunar Day and Month
  lunarDay = dayNumber - monthStart + 1;
  var diff = ((monthStart - a11) / 29).floor(); 
  lunarMonth = diff + 11;

  // Leap Month Calculation
  if (b11 - a11 > 365) {
    var leapMonthDiff = getLeapMonthOffset(a11, timeZone);
    if (diff >= leapMonthDiff) {
      lunarMonth = diff + 10;
      if (diff == leapMonthDiff) {
        lunarLeap = 1; 
      }
    }
  }

  // Adjustments
  if (lunarMonth > 12) {
    lunarMonth = lunarMonth - 12;
  }
  if (lunarMonth >= 11 && diff < 4) {
    lunarYear -= 1;
  }

  return [lunarDay, lunarMonth, lunarYear, lunarLeap]; 
}

/* Convert a lunar date to the corresponding solar date */
List<int> convertLunar2Solar(int lunarDay, int lunarMonth, int lunarYear, int lunarLeap, double timeZone) {
  var k, a11, b11, off, leapOff, leapMonth, monthStart;

  // Determine a11 and b11 for Lunar Year Calculation
  if (lunarMonth < 11) {
    a11 = getLunarMonth11(lunarYear - 1, timeZone);
    b11 = getLunarMonth11(lunarYear, timeZone);
  } else {
    a11 = getLunarMonth11(lunarYear, timeZone);
    b11 = getLunarMonth11(lunarYear + 1, timeZone);
  }

  // Calculate k and Offset
  k = (0.5 + (a11 - 2415021.076998695) / 29.530588853).floor();
  off = lunarMonth - 11;
  if (off < 0) {
    off += 12;
  }

  // Leap Month Adjustments
  if (b11 - a11 > 365) {
    leapOff = getLeapMonthOffset(a11, timeZone);
    leapMonth = leapOff - 2;
    if (leapMonth < 0) {
      leapMonth += 12;
    }
    if (lunarLeap != 0 && lunarMonth != leapMonth) {
      return [0, 0, 0]; // Indicate conversion error
    } else if (lunarLeap != 0 || off >= leapOff) {
      off += 1;
    }
  }

  // Determine Month Start and Convert Back to Solar Date
  monthStart = getNewMoonDay(k + off, timeZone);
  return jdToDate(monthStart + lunarDay - 1); 
}

getCanChiYear(int year) {
  var can = canList[year % 10];
  var chi = chiList[year % 12];
  return '${can} ${chi}';
}

getCanChiMonth(int month, int year) {
  var chi = chiForMonthList[month - 1];
  var indexCan = 0;
  var can = canList[year % 10];

  if (can == "Giáp" || can == "Kỉ") {
    indexCan = 6;
  }
  if (can == "Ất" || can == "Canh") {
    indexCan = 8;
  }
  if (can == "Bính" || can == "Tân") {
    indexCan = 0;
  }
  if (can == "Đinh" || can == "Nhâm") {
    indexCan = 2;
  }
  if (can == "Mậu" || can == "Quý") {
    indexCan = 4;
  }
  return '${canList[(indexCan + month - 1) % 10]} ${chi}';
}

// getDayName(lunarDate) {
//  if (lunarDate.day == 0) {
//    return "";
//  }
//  var cc = getCanChi(lunarDate);
//  var s = "Ngày " + cc[0] +", tháng "+cc[1] + ", năm " + cc[2];
//  return s;
//}

getYearCanChi(year) {
  return CAN[(year + 6) % 10] + " " + CHI[(year + 8) % 12];
}

getCanHour(jdn) {
  return CAN[(jdn - 1) * 2 % 10];
}

getCanDay(jdn) {
  var dayName, monthName, yearName;
  dayName = CAN[(jdn + 9) % 10] + " " + CHI[(jdn + 1) % 12];
  return dayName;
}

jdn(dd, mm, yy) {
  var a = INT((14 - mm) / 12);
  var y = yy + 4800 - a;
  var m = mm + 12 * a - 3;
  var jd = dd +
      INT((153 * m + 2) / 5) +
      365 * y +
      INT(y / 4) -
      INT(y / 100) +
      INT(y / 400) -
      32045;
  return jd;
}

getGioHoangDao(jd) {
  var chiOfDay = (jd + 1) % 12;
  var gioHD = GIO_HD[chiOfDay %
      6]; // same values for Ty' (1) and Ngo. (6), for Suu and Mui etc.
  var ret = "";
  var count = 0;
  for (var i = 0; i < 12; i++) {
    if (gioHD.substring(i, i + 1) == '1') {
      ret += CHI[i];
      ret += ' (${{(i * 2 + 23) % 24}}-${{(i * 2 + 1) % 24}})';
      if (count++ < 5) ret += ', ';
      if (count == 3) ret += '\n';
    }
  }
  return ret;
}

getTietKhi(jd) {
  return TIETKHI[getSunLongitude(jd + 1, 7.0)];
}

getBeginHour(jdn) {
  return CAN[(jdn - 1) * 2 % 10] + ' ' + CHI[0];
}

int getLunarDay(DateTime dateTime) {
  var lunarDates =
      convertSolar2Lunar(dateTime.day, dateTime.month, dateTime.year, 7);
  var lunarDay = lunarDates[0];
  return lunarDay;
}

int getLunarMonth(DateTime dateTime) {
  var lunarDates =
      convertSolar2Lunar(dateTime.day, dateTime.month, dateTime.year, 7);
  var lunarMonth = lunarDates[1];
  return lunarMonth;
}

int getLunarYear(DateTime dateTime) {
  var lunarDates =
      convertSolar2Lunar(dateTime.day, dateTime.month, dateTime.year, 7);
  var lunarYear = lunarDates[2];
  return lunarYear;
}

String getCanchiDay(DateTime dateTime) {
  var jd = jdn(dateTime.day, dateTime.month, dateTime.year);
  var dayName = getCanDay(jd);
  return dayName;
}

String getCanchiMonth(DateTime dateTime) {
  var lunarDates =
      convertSolar2Lunar(dateTime.day, dateTime.month, dateTime.year, 7);
  var lunarMonth = lunarDates[1];
  var lunarYear = lunarDates[2];
  var lunarMonthName = getCanChiMonth(lunarMonth, lunarYear);
  return lunarMonthName;
}