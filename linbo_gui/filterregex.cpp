#include "filterregex.h"
#include <QString>
#include <QTextCodec>

FilterRegex::FilterRegex(const QString maxPattern, const QString valPattern)
{
    _maximum = 100;
    _value = 0;
    codec = QTextCodec::codecForName("UTF-8");
    maxMatcher = QRegularExpression(maxPattern);
    _maxMatched = false;
    valMatcher = QRegularExpression(valPattern);
}

FilterRegex::~FilterRegex()
{
    // Qt deletes codec !
    return;
}

void FilterRegex::filter(const QByteArray &output)
{
    QString s = codec->toUnicode(output);
    if(!_maxMatched){
        QRegularExpressionMatch max = maxMatcher.match(s);
        if(max.hasMatch()){
            _maxMatched = true;
            bool ok;
            int tmp = max.captured(2).toInt(&ok);
            if(ok)
                _maximum = tmp;
        }
    }
    QRegularExpressionMatch val = valMatcher.match(s);
    if(val.hasMatch()){
        bool ok;
        int tmp = val.captured(1).toInt(&ok);
        if(ok)
            _value = tmp;
    }
}

int FilterRegex::maximum()
{
    return _maximum;
}

int FilterRegex::value()
{
    return _value;
}
