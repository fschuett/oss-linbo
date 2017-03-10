#ifndef FILTERREGEX_H
#define FILTERREGEX_H

#include <QRegularExpression>
#include <QTextCodec>

#include "filter.h"

class FilterRegex : public Filter
{
private:
    int _maximum;
    int _value;
    QTextCodec *codec;
    QRegularExpression maxMatcher;
    bool _maxMatched;
    QRegularExpression valMatcher;

public:
    FilterRegex(const QString maxPattern, const QString valPattern);
    virtual ~FilterRegex();
    virtual void filter(const QByteArray &output);
    virtual int maximum();
    virtual int value();
};

#endif // FILTERREGEX_H
