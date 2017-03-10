#include "filtertime.h"
#include <QDebug>

FilterTime::FilterTime(QTimeEdit *new_timer = NULL):timer(new_timer)
{
    return;
}

FilterTime::~FilterTime(){

}

void FilterTime::filter(const QByteArray &output)
{
    return;
}

int FilterTime::maximum()
{
    return 100;
}

int FilterTime::value()
{
    if(timer != 0)
        return timer->time().second()*10/6;
    else
        return 0;
}
