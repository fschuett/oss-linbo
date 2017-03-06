#ifndef FILTERTIME_H
#define FILTERTIME_H

#include <QTimeEdit>

class FilterTime : public Filter
{
    QTimeEdit timer;

public:
    FilterTime(&QTimeEdit new_timer = NULL);
};

#endif // FILTERTIME_H
