#include <time.h>

static struct tm tm;

# define LEAP_YEAR(_year) ((_year % 4) == 0)
# define YDAYS(_year) (LEAP_YEAR(year) ? 366 : 365)
struct tm *gmtime_r (const time_t *timep, struct tm *ptm)
{
    unsigned int year;
    int days, month, month_len;
    time_t t = *timep;
    ptm->tm_sec = t % 60;
    t /= 60;
    ptm->tm_min = t % 60;
    t /= 60;
    ptm->tm_hour = t % 24;
    t /= 24;
    ptm->tm_wday = (t+4) % 7;
    year = 70;
    days =  0;
    while ((days += YDAYS (year)) <= t)
    {
        year++;
    }
    ptm->tm_year = year;
    days -= YDAYS(year);
    t    -= days;
    ptm->tm_yday = t;
    for (month=0; month<12; month++)
    {
        if (month == 1)
        {
            month_len = LEAP_YEAR(year) ? 29 : 28;
        }
        else
        {
            int m = month;
            if (m >= 7)
            {
                m -= 1;
            }
            m &= 1;
            month_len = m ? 30 : 31;
        }
        if (t >= month_len)
        {
            t -= month_len;
        }
        else
        {
            break;
        }
    }
    ptm->tm_mon   = month;
    ptm->tm_mday  = t + 1;
    ptm->tm_isdst = 0;
    return ptm;
}

struct tm *gmtime (const time_t *timep)
{
    return gmtime_r (timep, &tm);
}
