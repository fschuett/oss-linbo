#ifndef FILTER_H
#define FILTER_H

#include <qbytearray.h>

class Filter
{
public:
    Filter();
    virtual ~Filter();
    virtual void filter(const QByteArray& output);
    virtual int maximum();
    virtual int value();
};

#endif // FILTER_H
