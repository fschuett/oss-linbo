#ifndef FILTERTIME_H
#define FILTERTIME_H

#include <QTimeEdit>
#include "filter.h"

class FilterTime : public Filter
{
    QTimeEdit *timer;

public:
    FilterTime(QTimeEdit *new_timer);
    virtual ~FilterTime();
    virtual void filter(const QByteArray &output);
    virtual int maximum();
    virtual int value();
};

#endif // FILTERTIME_H
