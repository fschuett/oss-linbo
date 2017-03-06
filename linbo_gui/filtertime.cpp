#include "filtertime.h"

FilterTime::FilterTime(&QTimeEdit new_timer):timer(new_timer)
{

}

int FilterTime::maximum(const QByteArray& output)
{
    return 100;
}

int FilterTime::value(const QByteArray& output)
{
    return 0;
}
